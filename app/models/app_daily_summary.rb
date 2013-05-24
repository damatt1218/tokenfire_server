class AppDailySummary < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :summary_date, :dau_count, :session_count, :device_count, :total_duration, :average_duration

  belongs_to :app

  has_many :app_usages, through: :app, :uniq => true
  has_many :app_sessions, through: :app_usages, :uniq => true
  has_many :app_session_histories, through: :app_sessions, :uniq => true
  has_many :devices, through: :app_sessions, :uniq => true
  has_many :users, through: :devices, :uniq => true

  def self.update_for_date(app, update_date)

    app_daily_summary = app.app_daily_summaries.where(:summary_date => update_date).first_or_create()



    app_daily_summary.recalculate


  end

  def recalculate
    @query_start_datetime = self.summary_date.to_time.to_datetime.beginning_of_day.utc
    @query_end_datetime = @query_start_datetime + 1.day


    update_dau_count()
    update_session_count()
    update_device_count()
    update_duration()

    save
  end

  private

  def update_dau_count

    self.dau_count = self.users.where(:app_sessions => {:session_start => @query_start_datetime..@query_end_datetime}).length

        #app_usages.where(:app_sessions => {:session_start => start_time..end_time})
        #
        # .includes(:app_sessions)
        # .group(:account_id)

  end

  def update_session_count

    self.session_count = self.app_sessions.where(:session_start => @query_start_datetime..@query_end_datetime)
      .length
  end

  def update_device_count

    self.device_count = self.devices.where(:app_sessions => {:session_start => @query_start_datetime..@query_end_datetime})
      .length
  end

  def update_duration
    self.total_duration = self.app_sessions.where(:session_start => @query_start_datetime..@query_end_datetime)
      .sum(:session_duration) / 60
    self.average_duration = self.app_sessions.where(:session_start => @query_start_datetime..@query_end_datetime)
      .average(:session_duration) / 60
  end

end
