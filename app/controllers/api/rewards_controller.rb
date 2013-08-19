module Api

  require 'json'

  class RewardsController < ApplicationController
    # doorkeeper_for :all
    respond_to :json, :xml

     # GET /api/rewards.json
    def index

      @rewards = Reward.all
      @rewardlist = Array.new
      device = nil

      if params.has_key?(:device_uid)
        device = Device.find_by_uuid(params[:device_uid])
      end

      @rewards.collect do |reward|
        reward_image = nil

        if (reward.image.url != nil)
          app_image = "#{reward.image.url}"
          @rewardlist << { :id => reward.id, :name => reward.name, :description => reward.description, :cost => reward.cost, :quantity => reward.quantity, :image => app_image }
        else
          @rewardlist << { :id => reward.id, :name => reward.name, :description => reward.description, :cost => reward.cost, :quantity => reward.quantity }
        end
      end

      json_rewards = @rewardlist.to_json
      render status: 200, json: json_rewards
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

      @rewardlist = Array.new
      device = nil

      if params.has_key?(:device_uid)
        device = Device.find_by_uuid(params[:device_uid])
      end

      @rewards.collect do |reward|
        reward_image = nil

        if (reward.image.url != nil)
          app_image = "#{reward.image.url}"
          @rewardlist << { :id => reward.id, :name => reward.name, :description => reward.description, :cost => reward.cost, :quantity => reward.quantity, :image => app_image }
        else
          @rewardlist << { :id => reward.id, :name => reward.name, :description => reward.description, :cost => reward.cost, :quantity => reward.quantity }
        end
      end

      json_rewards = @rewardlist.to_json
      render status: 200, json: json_rewards
    end

  end
end
