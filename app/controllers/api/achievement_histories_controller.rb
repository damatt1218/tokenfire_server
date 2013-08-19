module Api

  require "erb"
  # Controller for the Achievement History API
  # Enables devices to report achievement accomplishment
  class AchievementHistoriesController < ApplicationController

    include ERB::Util

    # Require OAuth to access this controller
    doorkeeper_for :all

    # POST /api/achievements/report - Creates a new achievement history
    #   Expects JSON passed in this format:
    #     {
    #       "achievement_uid": The UID of the achievement to report
    #       "device_uid": The UID of for the users device
    #       "acquired" : The datetime of when the achievement was acquired
    #     }
    def report

      #Check for the needed parameter, return error if not populated
      achievement_uid = params[:achievement_uid]
      device_uid = params[:device_uid]
      acquired_date = params[:acquired]

      # Validate that the request contains valid parameters
      valid_parameters = true
      if achievement_uid.nil? || achievement_uid == '' ||
                device_uid.nil? || device_uid == 'UNKNOWN' || device_uid == ''
        valid_parameters = false
      end


      if valid_parameters && save_achievement(achievement_uid, device_uid, acquired_date)
        render_status = 200
        notification_string = "You have earned #{amount} tokens through #{source}!"
        if !Device.find_by_uuid(device_uid).gcm_id.nil?
          n = Rapns::Gcm::Notification.new
          n.app = Rapns::Gcm::App.find_by_name("TokenFire")
          n.registration_ids = [Device.find_by_uuid(device_uid).gcm_id]
          n.data = {:message => notification_string}
          n.save!
          Rapns.push
        end
        report_to_apsalar(Achievement.find_by_uid(achievement_uid))
        response = {result: 'Success'}
      else
        render_status = 400
        response = {result: 'Error'}
      end

      render status: render_status, json: response
    end

    # GET /api/achievements/status?device_uid=<UUID>&app_id=<app_id>
    #  Gets a list of achievements available for the current app and if they have been achieved
    #    device_uid (required) - The device we the achievements are associated with
    #    app_id (optional) - The app the achievements are for (TokenFire app only)
    def status
      device_uid = params['device_uid']
      app_id = params['app_id']

      achievements = get_achievements(device_uid, app_id)
      if achievements
        status = 200
        json = achievements
      else
        status = 500
        json = 'Error'
      end

      render :status => status, :json => json
    end

    # Gets the achievements associated with an application
    #  device_uid (required) - The UID of the device the achievements are associated with
    #  app_id (optional) - The app the achievements are associated with (TokenFire app only)
    private
    def get_achievements(device_uid, app_id)
      # Maker sure the device uid has been provided
      if device_uid.nil? || device_uid == ''
        return false
      end

      # Get the user, app, and device
      user = current_user

      # if its the token fire app
      #   app_id = params['app_id']
      #   app = App.find(app_id)
      # else
      app = current_application
      # end



      if (app_id)
        app = App.find_by_id(app_id)
      end

      device = Device.find_by_uuid(device_uid)

      # Validate there are no nil values
      if user.nil? || app.nil? || device.nil?
        return false
      end

      # Make sure the device specified belongs to the requesting user
      if device.user_id != user.id
        return false
      end

      downloaded_through_tokenfire = false
      user.devices.each do |device|
        if device.hasDownloadWithAppDownloadId(app.id)
          downloaded_through_tokenfire = true
        end

      end

      user_achievements_infos = Array.new

      app.achievements.each do |achievement|

        # if the achievement is not available to the user
        #   next
        # end
        if !downloaded_through_tokenfire
          next
        end

        unless achievement.enabled
          next
        end

        # Find the achievement history is it already exists
        begin
          achievement_history = AchievementHistory.where(:device_id => device.id).
              where(:achievement_id => achievement.id).
              limit(1).first
        rescue
          # ignored
        end

        has_achievement = !achievement_history.nil?

        user_achievement_info = UserAchievementInfo.new
        user_achievement_info.populate(achievement, has_achievement)

        user_achievements_infos.push(user_achievement_info)
      end

      return user_achievements_infos
    end


    # Saves an achievement for given device if valid
    #  achievement_uid - The UID associated with the achievement being reported (UID, not ID)
    #  device_uid - The UID associated with the device the achievement was achieved on
    private
    def save_achievement (achievement_uid, device_uid, acquired_date)
      user = current_user
      app = current_application
      achievement = Achievement.find_by_uid(achievement_uid)
      device = Device.find_or_create_by_uuid(device_uid)

      # If we just created the device, attach the user to it
      if device.user.nil?
        device.user = user
      end

      # Make sure the device matches the user
      if device.user != user
        logger.error 'Device/user mismatch found when reporting achievement'
        return false
      end

      # Make sure the achievement matches the app
      if achievement.nil? || achievement.app_id != app.id
        log.error 'Achievement/app mismatch found when reporting achievement'
        return false
      end

      # Find the achievement history is it already exists
      begin
        achievement_history = AchievementHistory.where(:device_id => device,
                                                       :achievement_id => achievement).
            limit(1).first
      rescue
        # ignored
      end

      # The achievement should be recorded if a previous record doesn't exist
      record_achievement = (achievement_history.nil?)
      # OR the one exists already and it is repeatable
      record_achievement ||= (!achievement_history.nil?) && (achievement.repeatable?)
      # AND it is enabled
      record_achievement &&= (achievement.enabled?)

      # The user should be paid for the achievement if they meet any special requirements
      payout = record_achievement # TODO - Check for special cases when the achievement is only available to some users

      # Record the achievement
      if record_achievement
        achievement_history = AchievementHistory.new
        achievement_history.achievement = achievement
        achievement_history.device = device
        achievement_history.acquired = acquired_date

        # Only pay the user after successfully saving
        payout &&= achievement_history.save
      end

      # Pay the user
      if payout
        user.account.balance += achievement.value.to_f
        user.account.save

        # TODO - Where do we record how much the developer owes us?
      end
    end

    # Gets the current user from the door keeper token
    private
    def current_user
      User.find_by_id(doorkeeper_token.resource_owner_id)
    end

    # Gets the current application from the door keeper token
    private
    def current_application
      App.find_by_id(doorkeeper_token.application_id)
    end

  end

  # Class for providing a user info about the achievements for an app
  class UserAchievementInfo
    # Name of the achievement
    attr_accessor :name,
                  # Description of the achievements
                  :description,
                  # How many "tokens" a user gets for acquiring the achievements
                  :value,
                  # True if a user can acquire the achievements multiple times
                  :repeatable,
                  # True if the user has already achieved this achievement
                  :achieved

    # Populates the object from other data
    #  achievement - The Achievement this object represents
    #  has_achievements - If true, the achievement has already be achieved by the user
    def populate (achievement, has_achievement)
      self.name = achievement.name
      self.description = achievement.description
      self.value = achievement.value
      self.repeatable = achievement.repeatable
      self.achieved = has_achievement
    end
  end

  private
  def report_to_apsalar(achievement)

    apsalarSecret = "m6QEEspq"

    apsalarUrl  = "http://api.apsalar.com/api/v1/event?"

    # u: device ID -  required, use a dummy one for now
    # a: apsalar API key
    # av: app version number
    # i: class package
    # k: keyspace (ANDI means android ID - which tells apsalar that the device ID is an android ID)
    # n: name of the event
    # p: platform
    # s: session ID
    # h: hash
    queryString = "u=d22abcccae2928e2&a=tokenfire&av=1.0&i=com.tokenfire.tokenfire&k=ANDI&p=Android&s=7b4a7a01-e2c5-4f43-9b9c-73f4f9e57f21"
    queryString += "&n=" + url_encode(achievement.name) + "Achieved"
    queryString += "&e=" + url_encode(achievement.to_json.force_encoding("utf-8"))
    hash = "&h=" + Digest::SHA1.hexdigest(apsalarSecret + "?" + queryString)
    response = HTTParty.get(apsalarUrl + queryString + hash)
  end

end