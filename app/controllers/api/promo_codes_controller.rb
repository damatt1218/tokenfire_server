module Api

  require 'json'

  class PromoCodesController  < ApplicationController
    doorkeeper_for :applyPromoCode
    respond_to :json, :xml

    TOKENS_FOR_REFERRER = 400
    TOKENS_FOR_REFERREE = 200

    # POST /api/promo_codes/apply_promo_code
    def applyPromoCode
      if params.has_key?(:android_id) && params.has_key?(:promo_code)
        device = Device.find_by_uuid(params[:android_id])
        if device.nil? || !device.user.registered
          render status: 400, text: "You must register before using promo codes."
        else
          account = device.user.account
          device = Device.find_by_uuid(params[:android_id])
          referral_account = Account.find_by_referral_code(params[:promo_code])

          # check if promo code matches an account
          if !referral_account.nil?
            if referral_account == account
              render status: 400, text: "Invalid referral code."
            else
              if account.referral_code_history.nil?
                referral_history = ReferralCodeHistory.find_or_create_by_account_id(account.id)
                referral_history.referrer_id = referral_account.id
                referral_history.referrer_value = TOKENS_FOR_REFERRER
                referral_history.referree_value = TOKENS_FOR_REFERREE
                referral_history.save

                if device
                  send_gcm(device, "a referral", TOKENS_FOR_REFERREE)
                end
                send_gcm_to_devices(referral_account.user.devices, "a referral", TOKENS_FOR_REFERRER)
                account.add_to_balance(TOKENS_FOR_REFERREE)
                referral_account.add_to_balance(TOKENS_FOR_REFERRER)
                account.save
                referral_account.save

                render status: 200, text: "Referral code accepted.  You have earned #{TOKENS_FOR_REFERREE} tokens!"
              else
                render status: 400, text: "You have already entered a referral code!"
              end
            end
          else
            # otherwise check if promo code matches an active promo code
            promo = PromoCode.find_by_name(params[:promo_code])
            if promo && promo.active == true
              if account.promo_code_histories.where(:promo_code_id => promo.id).count > 0
                render status: 400, text: "You have already received this promo!"
              else
                account.add_to_balance(promo.value)

                promo_history = PromoCodeHistory.new
                promo_history.account = account
                promo_history.promo_code = promo
                promo_history.value = promo.value
                promo_history.save
                send_gcm(device, "a promo code", promo.value)

                render status: 200, text: "Promo code accepted. You have earned #{promo.value} tokens!"
              end
            else
              render status: 400, text: "Invalid promo code!"
            end
          end
        end
      else
        render status: 400, text: "An error has occurred.  Please try again."
      end
    end

    def send_gcm_to_devices(devices, source, amount)
      devices.each do |d|
        send_gcm(d, source, amount)
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

  end

end
