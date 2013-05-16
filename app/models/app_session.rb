class AppSession < ActiveRecord::Base
  attr_accessible :reported_session_id, :session_duration, :session_start, :sdk_version

  belongs_to :app_usage
  belongs_to :device

  has_many :app_session_histories
end
