module Api

  require 'json'

  class RewardsController < ApplicationController
    # doorkeeper_for :all
    respond_to :json, :xml

     # GET /api/rewards.json
    def index
      @rewards = Reward.all
      Rabl.render(@rewards, 'api/rewards/index', view_path: 'app/views')
    end

    # Get /api/rewards/1.json
    def show
      @reward = Reward.find_by_id(params[:id])
      if (@reward)
        Rabl.render(@reward, 'api/rewards/show', view_path: 'app/views')
      else
        render status: 401, json: {error: "Invalid reward"}
      end
    end

    # GET /rewards/new
    def new
      render file: 'public/404.html', status: 401, layout: false
    end

    # GET /api/rewards/1/edit
    def edit
      render file: 'public/404.html', status: 401, layout: false
    end

    # POST /api/rewards
    def create
      parsed_json = JSON.parse(request.body.read)
      @reward = Reward.new(parsed_json["reward"])
      if @reward.save
        render status: 201, json: {message: @reward}
      else
        render status: 503, json: {error: "Reward not saved."}
      end

    rescue JSON::ParserError
      render status: 400, json: {error: "Invalid JSON"}

    rescue ActiveModel::MassAssignmentSecurity::Error
      render status: 403, json: {error: "Invalid JSON"}
    end

    # PUT /api/rewards/1
    def update
      @reward = Reward.find(params[:id])

      parsed_json = JSON.parse(request.body.read)

      if @reward.update_attributes(parsed_json["reward"])
        render status: 201, json: {message: @reward}
      else
        render status: 503, json: {error: "Reward not saved."}
      end

    rescue JSON::ParserError
      render status: 400, json: {error: "Invalid JSON"}

    rescue ActiveModel::MassAssignmentSecurity::Error
      render status: 403, json: {error: "Invalid JSON"}

    rescue ActiveRecord::RecordNotFound
      render status: 404, json: {error: "Not Found"}
    end

    def featured_rewards
      @rewards = Reward.where('featured_value > 0').order('featured_value desc')
      Rabl.render(@rewards, 'api/rewards/featured_rewards', view_path: 'app/views')
    end

  end
end
