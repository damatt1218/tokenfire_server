class AppsController < ApplicationController

  # Provides controller to help display all the apps associated with th current
  # user and a summary of statistics
  #  /apps
  def index
    @applications = App.find_all_by_account_id(current_user.account.id)

    # This should be pre-calculate when we start to get a real amount of data
    @users = 0
    @usageTime = 0
    @applications.each do |app|
       @users += app.accounts.count
       @usageTime += app.getTotalUsageTime
    end
  end

  # Provides application specific information
  #  /apps/<id>
  def show
    @application = App.find(params[:id])
    if(@application.account.id != current_user.account.id)
      redirect_to '/'
    end
  end

end