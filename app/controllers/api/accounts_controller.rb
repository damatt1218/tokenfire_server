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

    # POST /api/accounts/update_profile
    def updateProfile
      account = current_user.account

      if account.nil?
        render status: 400, json: {error: "Invalid User"}
      else
        if current_user.update_with_password(params[:user])
          render status: 200, json: {message: "Success"}
        else
          render status: 400, json: {error: "An error occurred. Please try again."}
        end
      end

    end


    def adcolonyVideoComplete
      adcolonyKey = "v4vc48eee7b6fed744908d7ffc"

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
                send_gcm(device, "adColony", params[:amount])
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
      tapjoyKey = "bJuBzs2k97YJU4j4OzMk"

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
                send_gcm(device, "TapJoy", params[:currency])
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
                send_gcm(device, "SponsorPay", params[:amount])
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

    def send_gcm(device, source, amount)
      notification_string = "You have earned #{amount} tokens through #{source}!"
      if !device.gcm_id.nil?
        n = Rapns::Gcm::Notification.new
        n.app = Rapns::Gcm::App.find_by_name("TokenFire")
        n.registration_ids = [device.gcm_id]
        n.data = {:message => notification_string}
        n.save!
        Rapns.push
      end
    end

    # /api/accounts/set_registration_id - sets the gcm_id for the device
    def setRegistrationId
      if (params.has_key?(:device_uid) && params.has_key?(:regid))
        device = Device.find_by_uuid(params[:device_uid])
        device.gcm_id = params[:regid]
        device.save
        render status: 200, text: ""
      else
        render status: 400, text: ""
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
          history.populate(r.reward.name, "Reward redeemed!", "#{r.reward.image.url}", r.reward.cost, r.created_at)
          returnUserHistories << history
        end

        achievements.each do |a|
          history = UserHistory.new
          history.populate(a.achievement.name, "Achievement Complete!", "#{a.achievement.app.image.url}", a.achievement.cost,
                           a.created_at)
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

        returnUserHistories = returnUserHistories.sort_by(&:date).reverse

        render status: 200, json: returnUserHistories
      end
    end

    private
    def report_to_apsalar(offerHistory)

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
