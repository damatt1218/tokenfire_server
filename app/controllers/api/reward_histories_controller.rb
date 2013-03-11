module Api

  require 'json'

  class RewardHistoriesController < ApplicationController
    doorkeeper_for :all
    respond_to :json, :xml

    # GET /api/reward_histories.json - Gets all reward histories stored in the datasource
    def index
      @histories = RewardHistory.all
      Rabl.render(@histories, 'api/reward_histories/index', view_path: 'app/views')
    end

    # Get /api/reward_histories/1.json - Gets a single account based on the history id
    def show
      @history = RewardHistory.find_by_id(params[:id])
      if (@history)
        Rabl.render(@history, 'api/reward_histories/show', view_path: 'app/views')
      else
        render status: 401, json: {error: "Invalid account"}
      end
    end

    # POST /api/reward_histories
    # Called to redeem a reward.
    #   Expects JSON passed in this format:
    #     {
    #         "reward_id":reward_id
    #     }
    def create
      parsed_json = JSON.parse(request.body.read)
      @history = RewardHistory.new(parsed_json)

      @history.account_id = current_user.account.id

      puts "******* in Reward Histories Controller ********"
      puts @history.account_id
      puts @history.reward_id
      puts "***********************************************"


      # Validate that the user has enough credit to redeem (create) the reward
      # Also decrement the cost of the reward from the user's balance.
      if @history.account && @history.reward
        reward_cost = 0
        if (@history.reward.cost.nil?)
          reward_cost = 0
        else
          reward_cost = @history.reward.cost
        end
        if @history.account.balance >= reward_cost
          @history.account.balance -= reward_cost
          if @history.save && @history.account.save
            render status: 201, json: {created: @history}
          end
        else
          render status: 200, json: {rejected: "Not enough credits."}
        end
      else
        render status: 503, json: {error: "Reward History not saved."}
      end

    rescue JSON::ParserError
      render status: 400, json: {error: "Invalid JSON"}
    rescue ActiveModel::MassAssignmentSecurity::Error
      render status: 403, json: {error: "Invalid JSON"}
    end

    # PUT /api/reward_histories/1
    def update
      @history = RewardHistory.find(params[:id])

      parsed_json = JSON.parse(request.body.read)

      if @history.update_attributes(parsed_json["reward_history"])
        render status: 201, json: {message: @history}
      else
        render status: 503, json: {error: "Reward History not saved."}
      end

    rescue JSON::ParserError
      render status: 400, json: {error: "Invalid JSON"}

    rescue ActiveModel::MassAssignmentSecurity::Error
      render status: 403, json: {error: "Invalid JSON"}

    rescue ActiveRecord::RecordNotFound
      render status: 404, json: {error: "Not Found"}
    end

    private
    def current_user
      @current_user ||= User.find_by_id(doorkeeper_token.resource_owner_id)
    end

  end
end
