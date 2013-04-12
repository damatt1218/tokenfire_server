class AppSessionHistory < ActiveRecord::Base
  attr_accessible :SessionDuration, :eventTimeStamp, :sdkVersion

  belongs_to :app_usage
  belongs_to :device
  has_many :device_metrics_histories
end
