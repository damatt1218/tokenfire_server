module Admin
  class RewardHistoriesController < AdminController

    # GET /reward_histories
    def index
      @pending_rewards = RewardHistory.find_all_by_processed(false)
      @fulfilled_rewards = RewardHistory.find_all_by_processed(true)

      respond_to do |format|
        format.html # index.html.erb
      end
    end

    # GET /reward_histories/1/edit
    def edit
      @reward_history = RewardHistory.find(params[:id])
    end


    # PUT /reward_histories/1
    # PUT /reward_histories/1.json
    def update
      @reward_history = RewardHistory.find(params[:id])

      respond_to do |format|
        if @reward_history.update_attributes(params[:reward_history])
          format.html { redirect_to admin_reward_histories_path, :notice => 'Redeemed Reward was successfully processed.' }
        else
          format.html { render :action => "edit" }
        end
      end
    end

  end
end
