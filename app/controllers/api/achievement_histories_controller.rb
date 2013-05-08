module Api

  # Controller for the Achievement History API
  # Enables devices to report achievement accomplishment
  class AchievementHistoriesController < ApplicationController

    # Require OAuth to access this controller
    doorkeeper_for :all

    # POST /api/achievements/report - Creates a new achievement history
    #   Expects JSON passed in this format:
    #     {
    #       "achievement_uid": The UID of the achievement to report
    #       "device_uid": The UID of for the users device
    #     }
    def report

      #Check for the needed parameter, return error if not populated
      achievement_uid = params["achievement_uid"]
      device_uid = params["device_uid"]

      # Validate that the request contains valid parameters
      validParameters = true
      if (achievement_uid.nil? || achievement_uid == "" ||
          device_uid.nil? || device_uid == "UNKNOWN" || device_uid == "")
        validParameters = false
      end


      if validParameters && save_achievement(achievement_uid, device_uid)
        renderStatus = 200
        response =  {result:"Success"}
      else
        renderStatus = 400
        response =  {result:"Error"}
      end

      render status: renderStatus, json: response
    end

    # Saves an achievement for given device if valid
    #  achievement_uid - The UID associated with the achievement being reported (UID, not ID)
    #  device_uid - The UID associated with the device the achievement was achieved on
    private
    def save_achievement (achievement_uid, device_uid)
      user = current_user
      app = current_application
      achievement = Achievement.find_by_uid(achievement_uid)
      device = Device.find_or_create_by_uuid(device_uid)

      # If we just created the device, attache the user to it
      if device.user.nil?
        device.user = user
      end

      # Make sure the device matches the user
      if device.user != user
        logger.error "Device/user mismatch found when reporting achievement"
        return false
      end

      # Make sure the achievement matches the app
      if achievement.nil? || achievement.app_id != app.id
        log.error "Achievement/app mismatch found when reporting achievement"
        return false
      end

      # Find the achievement history is it already exists
      begin
        achievementHistory = AchievementHistory.where(:device_id => device.id).
                                                where(:achievement_id => achievement.id).
                                                limit(1).first
      rescue
      end

      # The achievement should be recorded if a previous record doesn't exist
      recordAchievement = (achievementHistory.nil?)
      # OR the one exists already and it is repeatable
      recordAchievement ||= (!achievementHistory.nil?) && (achievement.repeatable?)
      # AND it is enabled
      recordAchievement &&= (achievement.enabled?)

      # The user should be paid for the achievement if they meet any special requirements
      payOut = recordAchievement # TODO - Check for special cases when the achievement is only available to some users

      # Record the achievement
      if recordAchievement
        achievementHistory = AchievementHistory.new
        achievementHistory.achievement = achievement
        achievementHistory.device = device

        # Only pay the user after successfully saving
        payOut &&= achievementHistory.save
      end

      # Pay the user
      if payOut
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
end