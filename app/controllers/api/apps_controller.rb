module Api

  require 'json'

  class AppsController < ApplicationController
    doorkeeper_for :create, :update
    respond_to :json, :xml

    # GET /api/apps.json - Gets all apps stored in the datasource
    def index
      @apps = Array.new
      App.find_all_by_accepted(true).each do |a|
        campaign = a.getActiveCampaign
        if !campaign.nil?
          if campaign.isAvailable
            @apps << a
          end
        end
      end

      @applist = Array.new
      device = nil

      if params.has_key?(:device_uid)
        device = Device.find_by_uuid(params[:device_uid])
      end

      @apps.collect do |app|
        app_image = nil
        available_tokens = get_available_tokens(app, device)

        if (app.image.url != nil)
          app_image = "#{app.image.url}"
          @applist << { :id => app.id, :name => app.name, :description => app.description, :url => app.url, :image => app_image, :rating => available_tokens, :timeRemaining => -1 }
        else
          @applist << { :id => app.id, :name => app.name, :description => app.description, :url => app.url, :rating => available_tokens, :timeRemaining => -1 }
        end
      end

      json_apps = @applist.to_json
      render status: 200, json: json_apps
    end

    # GET /api/apps/get_apps_for_device - Gets all apps that the passed in device has downloaded
    def getAppsForDevice

      if !params.has_key?(:device_uid)
        render status: 400, text: ""
      end

      @apps = Array.new
      device = Device.find_by_uuid(params[:device_uid])
      downloads = Download.find_all_by_device_id(device.id)

      downloads.each do |d|
        app = App.find_by_id(d.app_download_id)

        if d.pending == false && app.accepted == true
          @apps << app
        end
      end

      @applist = Array.new
      @apps.collect do |app|
        app_image = nil
        available_tokens = get_available_tokens(app, device)

        campaign_time_left = 0;
        campaign = device.getCampaignWithAppId(app.id)
        campaign_history = device.getCampaignHistoryWithAppId(app.id)
        if !campaign.nil? && !campaign_history.nil?
          if campaign.active && campaign.approved
           time_elapsed = Time.now - campaign_history.created_at
           if time_elapsed > (campaign.duration * 1.day)
             campaign_time_left = (campaign.duration * 1.day) - time_elapsed
           # campaign_time_left = 300
           end
          end
        end

        if (app.image.url != nil)
          app_image = "#{app.image.url}"
          @applist << { :id => app.id, :name => app.name, :description => app.description, :url => app.url, :image => app_image, :rating => available_tokens, :timeRemaining => campaign_time_left }
        else
          @applist << { :id => app.id, :name => app.name, :description => app.description, :url => app.url, :rating => available_tokens, :timeRemaining => campaign_time_left }
        end
      end

      json_apps = @applist.to_json
      render status: 200, json: json_apps
    end


    # Get /api/apps/1.json - Gets a single app based on the app_id
    def show
      @app = App.find_by_id(params[:id])
      if (@app)
        Rabl.render(@app, 'api/apps/show', view_path: 'app/views')
      else
        render status: 401, json: {error: "Invalid app"}
      end
    end

    # GET /apps/new  - Default route created from the 'resources :apps' in routes file.
    #                  Don't want this route to do anything.
    def new
      render file: 'public/404.html', status: 401, layout: false
    end

    # GET /api/apps/1/edit - Default route created from the 'resources :apps' in routes file.
    #                        Don't want this route to do anything.
    def edit
      render file: 'public/404.html', status: 401, layout: false
    end

    # POST /api/apps - Create a new app from a passed in JSON that represents a app object
    #   Expects JSON passed in this format:
    #     {
    #       "app":
    #       {
    #         "name":"name_of_app",
    #         "description":"description of app",
    #         "image":"image_path",
    #         "rating":numerical_rating
    #       }
    #     }
    #  The 'name' field must be unique on creation, or an exception will be thrown.
    #  All other fields are optional
    def create
      parsed_json = JSON.parse(request.body.read)
      @app = App.new(parsed_json["app"])
      if @app.save
        render status: 201, json: {message: @app}
      else
        render status: 503, json: {error: "App not saved."}
      end

    rescue JSON::ParserError
      render status: 400, json: {error: "Invalid JSON"}

    rescue ActiveModel::MassAssignmentSecurity::Error
      render status: 403, json: {error: "Invalid JSON"}
    end

    # PUT /api/apps/1 - Update an app based on the app_id
    #   Expects JSON passed in this format:
    #     {
    #       "app":
    #       {
    #         "name":"name_of_app",
    #         "description":"description of app",
    #         "image":"image_path",
    #         "rating":numerical_rating
    #       }
    #     }
    #  All fields are optional.  Updates will only occur on fields that
    #  are populated.  Other fields will retain their original value
    def update
      @app = App.find(params[:id])

      parsed_json = JSON.parse(request.body.read)

      if @app.update_attributes(parsed_json["app"])
        render status: 201, json: {message: @app}
      else
        render status: 503, json: {error: "App not saved."}
      end

    rescue JSON::ParserError
      render status: 400, json: {error: "Invalid JSON"}

    rescue ActiveModel::MassAssignmentSecurity::Error
      render status: 403, json: {error: "Invalid JSON"}

    rescue ActiveRecord::RecordNotFound
      render status: 404, json: {error: "Not Found"}
    end

    def featured_apps

      @apps = Array.new
      App.where('featured_value > 0').order('featured_value desc').each do |a|
        campaign = a.getActiveCampaign
        if !campaign.nil?
          if campaign.isAvailable
            @apps << a
          end
        end
      end

      @applist = Array.new

      @apps.collect do |app|
        app_image = nil

        if (app.image.url != nil)
          app_image = "#{app.image.url}"
          @applist << { :id => app.id, :name => app.name, :description => app.description, :url => app.url, :image => app_image }
        else
          @applist << { :id => app.id, :name => app.name, :description => app.description, :url => app.url }
        end
      end

      json_apps = @applist.to_json
      render status: 200, json: json_apps

     # Rabl.render(@apps, 'api/apps/featured_apps', view_path: 'app/views')
    end

    def get_available_tokens(app, device)
      available_tokens = 0
      tokens_achieved = 0

      campaign = device.getCampaignWithAppId(app.id)
      if campaign.nil?
        campaign = app.getActiveCampaign
      end

      if !campaign.nil?
        campaign.achievements.each do |achievement|
          if achievement.enabled
            available_tokens += achievement.value
          end
        end
      end

      if !device.nil?
        device.achievement_histories.each do |history|
          if history.achievement.app.id == app.id
            if history.achievement.enabled
              tokens_achieved += history.achievement.value
            end
          end
        end
      end

      if available_tokens > tokens_achieved
        return (available_tokens - tokens_achieved)
      else
        return 0
      end
    end

    private
    def current_user
      @current_user ||= User.find_by_id(doorkeeper_token.resource_owner_id)
    end

  end
end
