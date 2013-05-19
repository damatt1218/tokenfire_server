module Api

require 'json'

  class ClientSdkApiController < ApplicationController
  doorkeeper_for :all
  respond_to :json

  def validate_app_id
    # Process should be as follows:

    # 1- Validate the app_id and make sure funds are available


    app = App.find_all_by_uid(params[:app_id])

    # TODO:  finish this by validating funds

    if app.empty?
      render status: 401, json: {error: "Invalid app_id"}
    else
      format.json { render json: true, status: :found, location: app }
    end

  end


  # PUT /post_session_history.json
  def post_session_history
    # Process should be as follows:

    parsedReport = JSON.parse(params[:SessionHistory])


    # 1- Validate the app_id and make sure funds are available
    app = App.find_all_by_uid(parsedReport['appID'])


    if app.empty?
      render status: 401, json: {error: "Invalid app_id"}
      return
    end

    app = app.first



    # 2- Create a new app session history entry

    #  we need a device entry..
    session_device = Device.find_or_create_by_uuid(parsedReport['deviceID'])



    app_session = session_device.app_sessions.where(:reported_session_id => parsedReport['sessionID'])
        .first_or_create(:sdk_version => parsedReport['sdkVersion'])

    if app_session.session_start.nil?
      app_session.session_start = DateTime.parse(parsedReport['sessionStartTimeStamp']).utc
    end

    if app_session.app_usage.nil?
      app_session.app_usage = AppUsage.find_or_create_by_app_id_and_user_id(app.id, session_device.user_id)
    end


    app_session.session_duration = (app_session.session_start - parsedReport['timeStamp'].to_datetime) * -1


    app_session_history = app_session.app_session_histories.new
    app_session_history.event_timestamp= parsedReport['timeStamp']
    app_session_history.reported_duration = parsedReport['duration']






    # 3- Perform some validation..   we can't just trust every client, can we?
    # TODO:  finish this
    #@search_session_history = AppSessionHistory.find_active_session(@read_session_history.session_id, @read_session_history.device_id)





    # 5- If device metrics exist,  Extract and save them.
    metricParams = parsedReport['deviceStats']
    unless metricParams.nil?
      metricHistories = app_session_history.device_metrics_histories

      if metricHistories.empty?
        newMetricHistory = app_session_history.device_metrics_histories.new
        newMetricHistory.AppVersion = metricParams['appVersion']
        newMetricHistory.OS_version = metricParams['osVersion']
        newMetricHistory.Carrier = metricParams['carrier']
        newMetricHistory.Resolution = metricParams['resolution']
        newMetricHistory.Locale = metricParams['locale']
        newMetricHistory.Device_Type = metricParams['platform']
        newMetricHistory.OS = metricParams['osName']
      else

      end
    end

    # 4- Save the session history item
    if app_session.save
      render json: app_session, status: :created
    else
      render json: app_session.errors, status: :unprocessable_entity
      return
    end


    app.update_analytics

  end

  end
end
