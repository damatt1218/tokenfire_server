module Api

  require 'json'

  class DownloadsController  < ApplicationController
    # doorkeeper_for :all
    respond_to :json, :xml

    # POST /api/clicked_download_app
    # Called when a download link is clicked within an app.
    #   Expects JSON passed in this format:
    #     {
    #         "device_uid":device_uid,
    #         "download_app_pkg":download_app_pkg,
    #         "refering_app_pkg":refering_app_pkg
    #     }
    def clicked_download_app
      parsed_json = JSON.parse(request.body.read)

      device_id = parsed_json["device_uid"]
      download_app_pkg = parsed_json["download_app_pkg"]
      refering_app_pkg = parsed_json["refering_app_pkg"]

      download_app = App.find_by_name(download_app_pkg)
      refering_app = App.find_by_name(refering_app_pkg)

      download = Download.find_or_create_by_device_id_app_id_and_app_download_id(
          device_id, refering_app.id, download_app.id)

      download.link_click_time = Time.now
      download.pending = true
      download.save

      redirect_string = "https://play.google.com/store/apps/details?id=" +
                        download_app.name +
                        "&referrer=utm_source%3D" +
                        refering_app.name

      if download
        redirect_to redirect_string
      else
        render status: 401, json: {error: "Invalid download"}
      end

    end

    # POST /api/initial_app_launch
    # Called when a newly downloaded app is launched for the first time.
    #   Expects JSON passed in this format:
    #     {
    #         "device_uid":device_uid,
    #         "app_uid":api_key,
    #         "refering_app_pkg":refering_app_pkg
    #     }
    def initial_app_launch
      parsed_json = JSON.parse(request.body.read)

      device_id = parsed_json["device_uid"]
      app_pkg = parsed_json["app_uid"]
      refering_app_pkg = parsed_json["refering_app_pkg"]

      app = App.find_by_uid(app_uid)
      refering_app = App.find_by_name(refering_app_pkg)

      download = Download.find_or_create_by_device_id_app_id_and_app_download_id(
          device_id, refering_app.id, app.id)

      if !download.initial_launch_time
        download.initial_launch_time = Time.now
        download.pending = false
        download.save
      end

      if download
        render status: 200, text: ""
      else
        render status: 401, json: {error: "Invalid download"}
      end

    end

  end


end