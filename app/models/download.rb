class Download < ActiveRecord::Base
  attr_accessible :device_id,
                  # ID of the app that originated this download (referrer)
                  :app_id,
                  :pending,
                  :link_click_time,
                  :initial_launch_time,
                  # ID of the downloaded app
                  :app_download_id

  # Relationships
  belongs_to :device
  belongs_to :app

  def self.find_or_create_by_device_id_app_id_and_app_download_id(device_id, app_id, app_download_id)
    newDownload = Download.where(:device_id => device_id,
                                 :app_id => app_id,
                                 :app_download_id => app_download_id).first_or_create()
    return newDownload
  end

  def check_for_valid_download(device_id, app_id)
    download = Download.where(:device_id => device_id,
                              :app_download_id => app_id)

    if !download.nil?
      tokenfire_app = App.where(:url => "com.tokenfire.tokenfire")
      if !tokenfire_app.nil?
        if download.app_id == tokenfire_app.app_id
          return true
        end
      end
    end

    return false
  end


end
