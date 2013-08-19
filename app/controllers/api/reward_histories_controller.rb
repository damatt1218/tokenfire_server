module Api

  require 'json'
  require "erb"

  class RewardHistoriesController < ApplicationController
    doorkeeper_for :all
    respond_to :json, :xml

    include ERB::Util

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
          if (!@history.reward.quantity.nil? && @history.reward.quantity == 0)
            render status: 200, json: {rejected: "Sorry, this reward is no longer available."}
          else
            @history.account.balance -= reward_cost
            if (!@history.reward.quantity.nil? && @history.reward.quantity > 0)
              @history.reward.quantity -= 1
            end
            if @history.save && @history.account.save
              report_to_apsalar(@history.reward)
              render status: 201, json: {created: @history}
            end
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

    private
    def report_to_apsalar(reward)

      apsalarSecret = "m6QEEspq"

      apsalarUrl  = "http://api.apsalar.com/api/v1/event?"

      # u: device ID -  required, use a dummy one for now
      # a: apsalar API key
      # av: app version number
      # i: class package
      # k: keyspace (ANDI means android ID - which tells apsalar that the device ID is an android ID)
      # n: name of the event
      # p: platform
      # s: session ID
      # h: hash
      queryString = "u=d22abcccae2928e2&a=tokenfire&av=1.0&i=com.tokenfire.tokenfire&k=ANDI&p=Android&s=7b4a7a01-e2c5-4f43-9b9c-73f4f9e57f21"
      queryString += "&n=" + url_encode(reward.name) + "Redeemed"
      queryString += "&e=" + url_encode(reward.to_json.force_encoding("utf-8"))
      hash = "&h=" + Digest::SHA1.hexdigest(apsalarSecret + "?" + queryString)
      response = HTTParty.get(apsalarUrl + queryString + hash)
    end

  end
end
