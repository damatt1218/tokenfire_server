module Api

  require 'json'

  class AppsController < ApplicationController
    doorkeeper_for :all, :except => :featured_apps
    respond_to :json, :xml

    # GET /api/apps.json - Gets all apps stored in the datasource
    def index
      @apps = App.all
      Rabl.render(@apps, 'api/apps/index', view_path: 'app/views')
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
      @apps = App.where('featured_value > 0').order('featured_value desc')
      Rabl.render(@apps, 'api/apps/featured_apps', view_path: 'app/views')
    end

  end
end
