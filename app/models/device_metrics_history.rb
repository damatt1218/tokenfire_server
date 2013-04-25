class DeviceMetricsHistory < ActiveRecord::Base
  attr_accessible :AppVersion, :Carrier, :Device_Type, :Location, :OS, :OS_version, :Resolution, :Locale


  belongs_to :app_session_history
end
