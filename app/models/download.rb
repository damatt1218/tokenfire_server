class Download < ActiveRecord::Base
  attr_accessible :device_id, :app_id, :pending, :link_click_time, :initial_launch_time, :app_download_id

  # Relationships
  belongs_to :device
  belongs_to :app

  def self.find_or_create_by_device_id_app_id_and_app_download_id(device_id, app_id, app_download_id)
    newDownload = Download.where(:device_id => device_id,
                                 :app_id => app_id,
                                 :app_download_id => app_download_id).first_or_create()
    return newDownload
  end


end
