module Api

  require 'json'

  class AppUsagesController < ApplicationController
    doorkeeper_for :all
    respond_to :json, :xml

    # GET /api/apps.json - Gets all apps stored in the datasource
    def index
      @apps = App.all
      Rabl.render(@apps, 'api/apps/index', view_path: 'app/views')
    end

    # Get /api/apps/1.json - Gets a single app based on the app_id
    def show
      @app = App.find_by_id(params[:id])
      if @app
        Rabl.render(@app, 'api/apps/show', view_path: 'app/views')
      else
        render status: 401, json: {error: "Invalid app"}
      end
    end

    # POST /api/app_usages - Create a new app from a passed in JSON that represents a app object
    #   Expects JSON passed in this format:
    #     {
    #       "appusage":
    #       {
    #         "account_id":id_of_account,    -- this will probably be retrieved automatically later
    #         "app_id":id_of_app,            -- this will probably be retrieved automatically later
    #         "usage_time":initilize_usage_time
    #       }
    #     }
    #  'user_id' and 'app_id' are required.  'usage_time' is optional for initializing time spent
    #  in app.
    def create
      parsed_json = JSON.parse(request.body.read)
      @appUsage = AppUsage.new(parsed_json["appusage"])
      if @appUsage.save
        render status: 201, json: {message: @appUsage}
      else
        render status: 503, json: {error: "App Usage not saved."}
      end

    rescue JSON::ParserError
      render status: 400, json: {error: "Invalid JSON"}

    rescue ActiveModel::MassAssignmentSecurity::Error
      render status: 403, json: {error: "Invalid JSON"}
    end


    # GET /api/app_usages/get_usage - Gets the usage time for a user and app
    # Expects JSON passed in this format:
    #   {
    #     "app_id":id_of_app,            -- this will probably be retrieved automatically later
    #   }
    # All fields are required
    def getUsageTime
      parsed_json = JSON.parse(request.body.read)

      app_id = parsed_json["app_id"]
      account_id = current_user.account.id

      if account_id.blank? || app_id.blank?
        render status: 400, json: {error: "Invalid JSON1"}
      else
        @appUsage = AppUsage.where(account_id: account_id).where(app_id: app_id).first
        if @appUsage.valid?
          render status: 200, json: {usageTime: @appUsage.usage_time}
        else
          render status: 400, json: {error: "Invalid JSON2"}
        end
      end



    rescue JSON::ParserError
      render status: 400, json: {error: "Invalid JSON"}
    end

    # POST /api/app_usages/increment_time - Increments by a certain amount the usage time
    #   Expects JSON passed in this format:
    #     {
    #       "appusage":
    #       {
    #         "app_id":id_of_app,            -- this will probably be retrieved automatically later
    #         "increment_time":time_to_increment_usage_time_by
    #       }
    #     }
    #  All fields are required
    def incrementTimeSpent
      parsed_json = JSON.parse(request.body.read)

      # getting values from the JSON
      usage_info = parsed_json["appusage"]

      if usage_info.blank?
        render status: 400, json: {error: "Invalid JSON"}
        return
      end

      app_id = usage_info["app_id"]
      increment_time = usage_info["increment_time"]
      account_id = current_user.account.id

      if account_id.blank? || app_id.blank? || increment_time.blank?
        render status: 400, json: {error: "Invalid JSON"}
      else
        @appUsage = AppUsage.where(account_id: account_id).where(app_id: app_id).first
        if @appUsage.valid?
          usage_time = @appUsage.usage_time
          @appUsage.update_column("usage_time", usage_time + increment_time)
          @appUsage.addCurrencyToAccount(account_id, increment_time)
          render status: 200, json: {message: @appUsage}
        else
          render status: 400, json: {error: "Invalid JSON"}
        end
      end

    rescue MultiJson::DecodeError
      render status: 400, json: {error: "Invalid JSON"}
    rescue JSON::ParserError
      render status: 400, json: {error: "Invalid JSON"}
    end

    private
    def current_user
      @current_user ||= User.find_by_id(doorkeeper_token.resource_owner_id)
    end
  end
end
