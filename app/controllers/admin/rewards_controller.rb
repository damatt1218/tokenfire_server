module Admin
  class RewardsController < AdminController

    def pending_redeemed
      @reward_histories = RewardHistory.find_all_by_processed(false)
      respond_to do |format|
        format.html # pending_redeemed.html.erb
      end
    end

  end
end
