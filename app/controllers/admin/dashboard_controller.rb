module Admin
  class DashboardController < AdminController
    def currency
      # Tokens to USD conversion
      @tokens_per_usd = 1000.0
      @offers_payout_per_token = 2 / 1000.0

      # Offers
      @offer_companies = OfferHistory.uniq.pluck(:company)
      @achievement_ids = AchievementHistory.uniq.pluck(:achievement_id)
      @promo_ids = PromoCodeHistory.uniq.pluck(:promo_code_id)
      @referral_ids = ReferralCodeHistory.uniq.pluck(:referrer_id)
      @reward_ids = RewardHistory.uniq.pluck(:reward_id)

      # Tokens
      @total_offer_tokens = OfferHistory.sum(:amount)
      @total_achievement_tokens = AchievementHistory.sum(:value)
      @total_reward_tokens = RewardHistory.sum(:amount, :conditions => {:processed => true})
      @total_promo_tokens = PromoCodeHistory.sum(:value)
      @total_referral_tokens = ReferralCodeHistory.sum(:referrer_value) + ReferralCodeHistory.sum(:referree_value)

      # Totals
      @total_earned_tokens = @total_offer_tokens + @total_achievement_tokens + @total_promo_tokens + @total_referral_tokens
      @unused_tokens = @total_earned_tokens - @total_reward_tokens
      @total_revenue = @total_offer_tokens * @offers_payout_per_token
      @realized_cost = @total_reward_tokens / @tokens_per_usd
      @unrealized_cost =  (@unused_tokens / @tokens_per_usd)

      @profit = @total_revenue - @unrealized_cost - @realized_cost

    end
  end
end
