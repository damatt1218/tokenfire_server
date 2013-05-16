class App < ActiveRecord::Base
  # Setup doorkeeper client extension
  if Doorkeeper.client.nil?
    puts 'Setting Doorclient model to App'
    doorkeeper_client!
  end


  attr_accessible :name, :redirect_uri
  attr_accessible :description, :image, :name, :rating

  # relationships
  has_many :app_usages

  has_many :accounts, through: :app_usages
  has_many :app_sessions, through: :app_usages
  has_many :achievements
  belongs_to :account

  def   getDailyActiveUsers(dau_date)

    # looks weird,  but the times are entered in utc,  and this is the only
    # way I can get the utc time of the dates we want to query
    start_time = dau_date.to_time.to_datetime.beginning_of_day.utc
    end_time = start_time + 1.days

   filtered_usages = app_usages.where(:app_sessions => {:session_start => start_time..end_time})
      .includes(:app_sessions)
      .group(:account_id)

    return filtered_usages.length
  end

  def getAverageSessionsPerDay
    days_app_active = (Time.zone.now - created_at).to_i / 1.day

    # count the current day
    days_app_active += 1

    average_sessions = getTotalSessionCount / days_app_active

    return average_sessions

  end

  def getAverageSessionLength
    average_session_length = app_sessions.average(:session_duration).to_i

    return average_session_length
  end

  def getTotalSessionCount

    total_sessions = app_sessions.count

    return total_sessions
  end

  def getTotalUsageTime
    total_time = 0

    for app_usages in self.app_usages do
      total_time += app_usages.usage_time
    end

    return total_time
  end

  def self.setDoorClient

    # doesn't really do anything.   This method is here
    # because this class gets lazy loaded,  and doorkeeper doesn't get
    # this is a bug in doorkeeper
  end
end
