module Admin
  class UsersController < AdminController
    #load_and_authorize_resource

    # GET /users
    # GET /users.json
    def index
      @users = User.all
      @pending_developers = []
      prospective_developer = Role.find_by_name("Prospective Developer")

      # Is this too intensive?
      @users.each do |user|
        if user.roles.include?(prospective_developer)
          @pending_developers << user
        end
      end

      respond_to do |format|
        format.html # index.html.erb
        format.json { render :json => @users }
      end
    end

    # GET /users/1
    # GET /users/1.json
    def show
      @user = User.find(params[:id])

      account = @user.account

        devices = Device.find_all_by_user_id(@user.id)
        device_ids = []
        devices.each do |d|
          device_ids << d.id
        end
        rewards = RewardHistory.where(:account_id => account.id)
        achievements = AchievementHistory.where(:device_id => device_ids)
        offers = OfferHistory.where(:device_id => device_ids)
        promos = PromoCodeHistory.where(:account_id => account.id)
        referrals = ReferralCodeHistory.where(:account_id => account.id)
        referrees = ReferralCodeHistory.where(:referrer_id => account.id)

        @returnUserHistories = []

        rewards.each do |r|
          history = UserHistory.new
          description_string = ""
          if r.processed == false
            description_string = "Pending reward"
          else
            description_string = "Reward redeemed!"
          end
          history.populate(r.reward.name, description_string, "#{r.reward.image.url}", "-#{r.amount}", r.created_at)
          @returnUserHistories << history
        end

        achievements.each do |a|
          history = UserHistory.new
          history.populate(a.achievement.name, "Achievement Complete!", "#{a.achievement.app.image.url}", a.achievement.cost,
                           a.created_at)
          @returnUserHistories << history
        end

        offers.each do |o|
          history = UserHistory.new
          history.name = o.company
          history.description = "Offer completed from: " + o.company + "!"
          history.amount = o.amount
          history.date = o.created_at
          @returnUserHistories << history
        end

        promos.each do |p|
          history = UserHistory.new
          history.name = "Promotional Code"
          history.description = "Promotional Code #{p.promo_code.name} redeemed!"
          history.amount = p.value
          history.date = p.created_at
          @returnUserHistories << history
        end

        referrals.each do |r|
          history = UserHistory.new
          history.name = "Referrer Install Bonus"
          history.description = "Referral code entered!"
          history.amount = r.referree_value
          history.date = r.created_at
          @returnUserHistories << history
        end

        referrees.each do |r|
          history = UserHistory.new
          history.name = "Referral Bonus"
          history.description = "#{r.account.user.username} entered your referral code!"
          history.amount = r.referrer_value
          history.date = r.created_at
          @returnUserHistories << history
        end

        @returnUserHistories = @returnUserHistories.sort_by(&:date).reverse


        respond_to do |format|
        format.html # show.html.erb
        format.json { render :json => @user }
        end

    end

    # GET /users/new
    # GET /users/new.json
    def new
      @user = User.new
      respond_to do |format|
        format.html # new.html.erb
        format.json { render :json => @user }
      end
    end

    # GET /users/1/edit
    def edit
      @user = User.find(params[:id])
    end

    # POST /users
    # POST /users.json
    def create
      @user = User.new(params[:user], :as => :admin)
      respond_to do |format|
        if @user.save
          flash[:notice] = flash[:notice].to_a.concat @user.errors.full_messages
          format.html { redirect_to admin_users_path, :notice => 'User was successfully created.' }
          format.json { render :json => @user, :status => :created, :location => @user }
        else
          flash[:notice] = flash[:notice].to_a.concat @user.errors.full_messages
          format.html { render :action => "new"}
          format.json { render :json => @user.errors, :status => :unprocessable_entity }
        end
      end
    end

    # PUT /users/1
    # PUT /users/1.json
    def update
      @user = User.find(params[:id])
      if params[:user][:password].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end

      respond_to do |format|
        if @user.update_attributes(params[:user], :as => :admin)
          format.html { redirect_to admin_users_path, :notice => 'User was successfully updated.' }
          format.json { head :ok }
        else
          format.html { render :action => "edit" }
          format.json { render :json => @user.errors, :status => :unprocessable_entity }
        end
      end
    end

    # DELETE /users/1
    # DELETE /users/1.json
    def destroy
      @user = User.find(params[:id])
      @user.destroy

      respond_to do |format|
        format.html { redirect_to admin_users_url }
        format.json { head :ok }
      end
    end
  end
end
