module Api

  require 'digest/md5'
  require 'erb'

  class AccountsController < ApplicationController
    doorkeeper_for :index, :show, :getHistories, :getProfile
    respond_to :json, :xml

    include ERB::Util

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
              report_to_apsalar(offerHistory)
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
                                              tapjoyKey)
        if (params[:verifier] != localHash)
          render status: 403, text: ""
        else
          offerHistory = OfferHistory.find_by_transaction_id(params[:id])
          if offerHistory
            render status: 403, text: ""
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
                render status: 200, text: ""
              else
                render status: 203, text: ""
              end

              offerHistory.save
              report_to_apsalar(offerHistory)
            else
              render status: 403, text: ""
            end
          end
        end
      end
    end

    def sponsorPayOfferComplete
      sponsorPayKey = "74c411229def263b1114b8062e26f81d"

      if (params.has_key?(:uid) &&
          params.has_key?(:sid) &&
          params.has_key?(:amount) &&
          params.has_key?(:_trans_id_))
        localHash = Digest::SHA1.hexdigest(sponsorPayKey +
                                           params[:uid] +
                                           params[:amount] +
                                           params[:_trans_id_])
        if (params[:sid] != localHash)
          render status: 403, text: ""
        else
          offerHistory = OfferHistory.find_by_transaction_id(params[:_trans_id_])
          if offerHistory
            render status: 200, text: ""
            # in SponsorPay documentation, return a 200 status code and ignore if it is duplicate
          else
            offerHistory = OfferHistory.find_or_create_by_transaction_id(params[:_trans_id_])
            offerHistory.amount = params[:amount]
            offerHistory.company = "SponsorPay"
            device = Device.find_by_uuid(params[:uid])
            if device
              if (device.user.account.balance.nil?)
                device.user.account.balance = params[:amount].to_i
              else
                device.user.account.balance += params[:amount].to_i
              end

              if (device.user.account.save)
                offerHistory.device = device
                render status: 200, text: ""
              else
                render status: 203, text: ""
              end

              offerHistory.save
              report_to_apsalar(offerHistory)
            else
              render status: 403, text: ""
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

        report_to_apsalar(OfferHistory.find_or_create_by_transaction_id(1363419925570))
        render status: 200, json: returnUserHistories
      end
    end

    private
    def report_to_apsalar(offerHistory)

      apsalarSecret = "KSC9ivQz"

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
      queryString = "u=d22abcccae2928e2&a=damatt&av=1.0&i=com.tokenfire.tokenfire&k=ANDI&p=Android&s=8266ded0-495c-4ac8-b1d8-4180e310964c" #"&h=a6006f38fdcdbd08fafcacd976eb1f802d867f9e"
      queryString += "&n=" + offerHistory.company + "Redemption"
      queryString += "&e=" + url_encode(offerHistory.to_json.force_encoding("utf-8"))
      hash = "&h=" + Digest::SHA1.hexdigest(apsalarSecret + "?" + queryString)
      response = HTTParty.get(apsalarUrl + queryString + hash)
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
