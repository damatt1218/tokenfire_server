module Api

require 'json'

  class ClientSdkApiController < ApplicationController

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

    # 1- Validate the app_id and make sure funds are available
    #@app = App.find_all_by_uid(params[:app_id])

    # TODO:  finish this by validating funds

    #if @app.empty?
    #  render status: 401, json: {error: "Invalid app_id"}
    #  return
    #end

    # TODO:  finish this



    # 2- Create a new app session history entry
    app_session_history = AppSessionHistory.new
    #todo:  better handling of active sessions

    app_session_history[:session_id] = params[:session_id]
    #app_session_history[:device] = Device.find_or_create(params[:device_uuid]).first
    app_session_history[:eventTimeStamp]= params[:timestamp]
    app_session_history[:sdkVersion]= params[:sdkVersion]
    app_session_history[:SessionDuration]= params[:duration]

    # 3- Perform some validation..   we can't just trust every client, can we?
    # TODO:  finish this
    #@search_session_history = AppSessionHistory.find_active_session(@read_session_history.session_id, @read_session_history.device_id)


    # 4- Save the session history item
    respond_to do |format|
      if app_session_history.save
        format.json { render json: app_session_history, status: :created, location: app_session_history }
      else
        format.json { render json: app_session_history.errors, status: :unprocessable_entity }
      end
    end

    # 5- If device metrics exist,  Extract and save them.
    # TODO:  finish this by saving device metrics

    # 6-  if the session time exceeds the currency ceiling for time,  create some currency
    # TODO:  finish this by adding currency

  end

  end
end
