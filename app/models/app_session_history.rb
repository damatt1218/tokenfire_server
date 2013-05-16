class AppSessionHistory < ActiveRecord::Base
  attr_accessible :event_timestamp, :reported_duration, :event_type

  belongs_to :app_session

  has_many :device_metrics_histories
end
