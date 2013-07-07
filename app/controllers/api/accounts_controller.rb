module Api

  require 'digest/md5'

  class AccountsController < ApplicationController
    doorkeeper_for :all, :except => :adcolonyVideoComplete
    respond_to :json, :xml

    # GET /api/accounts.json - Gets all accounts stored in the datasource
    def index
      @accounts = Account.all
      Rabl.render(@accounts, 'api/accounts/index', view_path: 'app/views')
    end

    # Get /api/accounts/1.json - Gets a single account based on the account_id
    def show
      @account = Account.find_by_id(params[:id])
      if (@account)
        Rabl.render(@account, 'api/accounts/show', view_path: 'app/views')
      else
        render status: 401, json: {error: "Invalid account"}
      end
    end

    # GET /api/accounts/get_profile - Gets profile for a user.  Currently just returns username and balance
    def getProfile
      account = current_user.account
      if account.nil?
        render status: 400, json: {error: "Invalid User"}
      else
        render status: 200, json: {username: current_user.username,
                                   email: current_user.email,
                                   firstName: current_user.first_name,
                                   lastName: current_user.last_name,
                                   company: current_user.company,
                                   balance: account.balance,
                                   registered: current_user.registered}
      end
    end


    def adcolonyVideoComplete
      adcolonyKey = "v4vc4ba1acf0703c4ebab1f87b"

      if (params.has_key?(:id) &&
          params.has_key?(:uid) &&
          params.has_key?(:amount) &&
          params.has_key?(:currency) &&
          params.has_key?(:verifier))
        localHash = Digest::MD5.hexdigest(params[:id] +
                                          params[:uid] +
                                          params[:amount] +
                                          params[:currency] +
                                          adcolonyKey)
        if (params[:verifier] != localHash)
          render :text => "vc_decline"
        else
          offerHistory = OfferHistory.find_by_transaction_id(params[:id])
          if offerHistory
            render :text => "vc_decline"
          else
            offerHistory = OfferHistory.find_or_create_by_transaction_id(params[:id])
            offerHistory.amount = params[:amount]
            offerHistory.company = "adColony"
            device = Device.find_by_uuid(params[:uid])
            if device
              if (device.user.account.balance.nil?)
                device.user.account.balance = params[:amount].to_i
              else
                device.user.account.balance += params[:amount].to_i
              end

              if (device.user.account.save)
                offerHistory.device = device
                render :text => "vc_success"
              else
                render :text => "retry_later"
              end

              offerHistory.save
            else
              render :text => "vc_decline"
            end
          end
        end
      end
    end

    def tapjoyOfferComplete
      tapjoyKey = "Nk0gZxliGJnQwE20NeUE"

      if (params.has_key?(:id) &&
          params.has_key?(:snuid) &&
          params.has_key?(:currency) &&
          params.has_key?(:verifier))
        localHash = Digest::MD5.hexdigest(params[:id] +
                                              params[:snuid] +
                                              params[:currency] +
                                              adcolonyKey)
        if (params[:verifier] != localHash)
          render status: 403
        else
          offerHistory = OfferHistory.find_by_transaction_id(params[:id])
          if offerHistory
            render status: 403
          else
            offerHistory = OfferHistory.find_or_create_by_transaction_id(params[:id])
            offerHistory.amount = params[:currency]
            offerHistory.company = "TapJoy"
            device = Device.find_by_uuid(params[:snuid])
            if device
              if (device.user.account.balance.nil?)
                device.user.account.balance = params[:currency].to_i
              else
                device.user.account.balance += params[:currency].to_i
              end

              if (device.user.account.save)
                offerHistory.device = device
                render status: 200
              else
                render status: 203
              end

              offerHistory.save
            else
              render status: 403
            end
          end
        end
      end
    end


    # GET /api/accounts/get_histories - Gets historical data for a user.
    #     includes Achievements, rewards, and (app usages?)
    def getHistories
      account = current_user.account
      if account.nil?
        render status: 400, json: {error: "Invalid User"}
      else
        devices = Device.find_all_by_user_id(current_user.id)
        device_ids = []
        devices.each do |d|
          device_ids << d.id
        end
        rewards = RewardHistory.find_all_by_account_id(account.id)
        achievements = AchievementHistory.where(:device_id => device_ids)
        offers = OfferHistory.where(:device_id => device_ids)

        returnUserHistories = []

        rewards.each do |r|
          history = UserHistory.new
          history.populate(r.reward.name, r.reward.description, r.reward.image, r.reward.cost, r.reward.created_at)
          returnUserHistories << history
        end

        achievements.each do |a|
          history = UserHistory.new
          history.populate(a.achievement.name, a.achievement.description, a.achievement.app.image, a.achievement.cost,
                           a.achievement.created_at)
          returnUserHistories << history
        end

        offers.each do |o|
          history = UserHistory.new
          history.name = o.company
          history.description = "Offer completed from: " + o.company + "!"
          history.amount = o.amount
          history.date = o.created_at
          returnUserHistories << history
        end

        render status: 200, json: returnUserHistories
      end
    end

    private
    def current_user
      @current_user ||= User.find_by_id(doorkeeper_token.resource_owner_id)
    end
  end

  class UserHistory
    attr_accessor :name, :description, :image, :amount, :date

    def populate(history_name, history_description, history_image, history_amount, history_date)
      self.name = history_name
      self.description = history_description
      self.image = history_image
      self.amount = history_amount
      self.date = history_date
    end

  end
end
