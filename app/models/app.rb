class App < ActiveRecord::Base
  # Setup doorkeeper client extension
  if Doorkeeper.client.nil?
    puts 'Setting Doorclient model to App'
    doorkeeper_client!
  end

  attr_accessible :name, :redirect_uri
  attr_accessible :description, :image, :name, :rating, :remote_image_url, :url, :disabled, :accepted, :submitted, :apk

  # Scopes
  scope :active, where(accepted: true, disabled: false)
  scope :submitted, where(accepted: false, disabled: false, submitted: true)
  scope :pending, where(accepted: false, disabled: false, submitted: false)
  scope :deleted, where(disabled: true)

  # Relationships
  has_many :downloads
  has_many :app_usages

  has_many :accounts, through: :app_usages
  has_many :app_sessions, through: :app_usages
  has_many :achievements
  has_many :campaigns
  has_many :app_daily_summaries
  belongs_to :account

  validates_presence_of :name

  mount_uploader :image, ImageUploader
  mount_uploader :apk, ApkUploader

  validate :validate_image_size
  validate :validate_package_name

  def validate_image_size
    if !image.nil? && !image.path.nil? && !image.to_s.include?("AKIAIWYJD4O3PQX4ETIA")
      open_image = MiniMagick::Image.open(image.path)
      unless open_image[:width] == 96 && open_image[:height] == 96
        errors.add :image, "should be 96x96px!"
      end
    end
  end

  def validate_package_name
    valid_url = false
    if !url.nil?
      valid_url = url.match(/[a-zA-Z]\w*([.]\w+)+/)
    end

    if !valid_url
      errors.add :package, "The package name is invalid. Package names must start with a character and can only contain characters, numbers, underscores and dots. They must have at least one dot, cannot end with a dot, and cannot contain any runs of more than one consecutive dot."
    end
  end

  def update_analytics
      # force an update of todays rollup stats for this app
      AppDailySummary.update_for_date(self, Date.today)

      self.app_usages.each { |app_usage| app_usage.update_usage_from_sessions }
  end

  def getDailyActiveUsers(dau_date)

    return app_daily_summaries.where(:summary_date => dau_date).sum(:dau_count)
  end

  def getMonthlyActiveUsers(mau_date)
    monthly_users = 0
    app_sessions.where(:session_start => mau_date.beginning_of_month..mau_date.end_of_month)
                     .uniq.pluck(:device_id).each do |device_id|
      if Device.find_by_id(device_id).hasDownloadWithAppDownloadId(self.id) == true
        monthly_users += 1
      end
    end
    return monthly_users
    #return app_daily_summaries.where(:summary_date => mau_date.beginning_of_month..mau_date.end_of_month).length
  end

  def getAverageSessionsPerDay
    days_app_active = (Time.zone.now - created_at).to_i / 1.day

    # count the current day
    days_app_active += 1

    average_sessions = 1.0 * getTotalSessionCount / days_app_active

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

    average_sessions = 1.0 * getTotalSessionCount / months_app_active

    return average_sessions
  end

  def getTotalSessionCount

    # total_sessions = app_sessions.count
    total_sessions = 0

    #need to count all app_sessions whose device has a download whose app_download_id is this app_id
    app_sessions.each do |session|
      if (session.device.hasDownloadWithAppDownloadId(self.id))
        total_sessions += 1
      end
    end

    return total_sessions
  end

  def getTotalUsageTime

    return app_daily_summaries.sum(:total_duration)
  end

  def getAverageAchievements
    achievement_count = AchievementHistory.joins(:achievement).where("app_id = ?", self.id).count
    devices_with_app = Download.where(:app_download_id  => self.id,
                                       :pending => false).count

    average_achievements = 0.0

    if devices_with_app > 0
      average_achievements = 1.0 * achievement_count / devices_with_app
    end

    return average_achievements

  end

  def getAverageDurationForAchievement(achievement)
    session_total = 0
    # Get achievement histories for the achievement
    achievement_histories = AchievementHistory.where(:achievement_id => achievement.id)
    achievement_histories.each do |history|
      sessions = app_sessions.where("session_start < ?", history.acquired)
      session_total += sessions.sum(:session_duration)
    end

    if achievement_histories.count > 0
      return 1.0 * session_total / achievement_histories.count
    else
      return 0.0
    end

  end

  def getActiveCampaign
    campaigns.each do |c|
      if c.active == true && c.approved == true
        return c
      end

      return nil
    end
  end


  def self.setDoorClient

    # doesn't really do anything.   This method is here
    # because this class gets lazy loaded,  and doorkeeper doesn't get
    # this is a bug in doorkeeper
  end
end
