class App < ActiveRecord::Base
  # Setup doorkeeper client extension
  if Doorkeeper.client.nil?
    puts 'Setting Doorclient model to App'
    doorkeeper_client!
  end


  attr_accessible :name, :redirect_uri
  attr_accessible :description, :image, :name, :rating, :remote_image_url, :url, :disabled

  # relationships
  has_many :downloads
  has_many :app_usages

  has_many :accounts, through: :app_usages
  has_many :app_sessions, through: :app_usages
  has_many :achievements
  has_many :app_daily_summaries
  belongs_to :account

  mount_uploader :image, ImageUploader

  def update_analytics
      # force an update of todays rollup stats for this app
      AppDailySummary.update_for_date(self, Date.today)

      self.app_usages.each { |app_usage| app_usage.update_usage_from_sessions }
  end

  def getDailyActiveUsers(dau_date)

    return app_daily_summaries.where(:summary_date => dau_date).length
  end

  def getAverageSessionsPerDay
    days_app_active = (Time.zone.now - created_at).to_i / 1.day

    # count the current day
    days_app_active += 1

    average_sessions = getTotalSessionCount / days_app_active

    return average_sessions

  end

  def getAverageSessionLength
   average_session_length = app_daily_summaries.average(:average_duration).to_i


    return average_session_length
  end

  def getAverageSessionsPerMonth

    months_app_active = (Time.zone.now - created_at).to_i / 1.month

    # count the current Month
    months_app_active += 1

    average_sessions = getTotalSessionCount / months_app_active

    return average_sessions
  end

  def getTotalSessionCount

    total_sessions = app_sessions.count

    return total_sessions
  end

  def getTotalUsageTime

    return app_daily_summaries.sum(:total_duration)
  end

  def self.setDoorClient

    # doesn't really do anything.   This method is here
    # because this class gets lazy loaded,  and doorkeeper doesn't get
    # this is a bug in doorkeeper
  end
end
