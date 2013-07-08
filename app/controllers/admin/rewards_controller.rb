module Admin
  class RewardsController < AdminController


    def index
      @rewards = Reward.all
      @featured_rewards = Reward.featured

      # Add this later
      # @featured_rewards
    end

    def show
      @rewards = Reward.find(params[:id])
    end

    def new
      @reward = Reward.new
    end

    def edit
      @reward = Reward.find(params[:id])
    end

    def create
      @reward = Reward.new(params[:reward], :as => :admin)

      if @reward.save
        redirect_to admin_rewards_path, :notice => 'Reward was successfully created.'
      else
        render :action => "new", :error => 'Could not create reward.'
      end
    end

    def update
      @reward = Reward.find(params[:id])

      if @reward.update_attributes(params[:reward], :as => :admin)
        redirect_to admin_rewards_path, :notice => 'Reward was successfully updated.'
      else
        render :action => "edit", :error => 'Could not update reward.'
      end
    end

    def destroy
      @reward = Reward.find(params[:id])

      if @reward.destroy
        redirect_to admin_users_url
      else

      end
    end

    def pending_redeemed
      @reward_histories = RewardHistory.find_all_by_processed(false)
      respond_to do |format|
        format.html # pending_redeemed.html.erb
      end
    end

  end
end
