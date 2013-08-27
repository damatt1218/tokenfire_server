module Admin
  class DashboardController < AdminController
    def currency
      # Tokens to USD conversion
      conversion_factor = 1 / 1000

      # Offer histories
      @offer_histories = OfferHistory.all
      @tapjoy_offer_histories = OfferHistory.find_all_by_company('tapjoy')
      @sponsorpay_offer_histories = OfferHistory.find_all_by_company('sponsorpay')
      @aarki_offer_histories = OfferHistory.find_all_by_company('aarki')
      @adcolony_offer_histories = OfferHistory.find_all_by_company('adcolony')
      @metap_offer_histories = OfferHistory.find_all_by_company('metap')

      # Achievement histories
      @achievement_histories = AchievementHistory.all

      # Reward histories
      @reward_histories = RewardHistory.all

      # Revenue
      @total_offer_revenue = 0
        @tapjoy_revenue = 0
        @sponsorpay_revenue = 0
        @aarki_revenue = 0
        @adcolony_revenue = 0
        @metap_revenue = 0
      @total_achievement_revenue = 0

      # Calculate revenues. Doubled because amount parameter is half.
      @offer_histories.each do |offer_history|
        @total_offer_revenue += offer_history.revenue
      end
      @tapjoy_offer_histories.each do |offer_history|
        @tapjoy_revenue += offer_history.amount * conversion_factor* 2
      end
      @sponsorpay_offer_histories.each do |offer_history|
        @sponsorpay_revenue += offer_history.amount * conversion_factor* 2
      end
      @aarki_offer_histories.each do |offer_history|
        @aarki_revenue += offer_history * conversion_factor* 2
      end
      @adcolony_offer_histories.each do |offer_history|
        @adcolony_revenue += offer_history * conversion_factor* 2
      end
      @metap_offer_histories.each do |offer_history|
        @metap_revenue += offer_history * conversion_factor* 2
      end
      @achievement_histories.each do |achievement_history|
        @total_achievement_revenue += achievement_history.value * conversion_factor * 2
      end

      # Costs
      @total_offer_cost = @total_offer_revenue / 2
      @total_achievement_cost = @total_achievement_revenue / 2
      @total_reward_cost = 0

      # Calculate costs
      @reward_histories.each do |reward_history|
        @total_reward_cost += reward_history.amount * conversion_factor
      end

      # Profit
      @total_revenue = @total_offer_revenue + @total_achievement_revenue
      @total_cost = @total_offer_cost + @total_achievement_cost + @total_reward_cost
      @profit = @total_revenue - @total_cost

    end
  end
end
