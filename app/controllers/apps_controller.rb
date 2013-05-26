class AppsController < ApplicationController
  include ActionView::Helpers::NumberHelper

  # Provides controller to help display all the apps associated with th current
  # user and a summary of statistics
  #  /apps
  def index
    if current_user.role? :admin
      @applications = App.all
    else
      @applications = App.find_all_by_account_id(current_user.account.id)
    end

    # This should be pre-calculate when we start to get a real amount of data
    @users = 0
    @usageTime = 0
    @dau = 0
    @dau_delta = 0
    @formatted_dau_delta = '0'

    @applications.each do |app|
       @users += app.accounts.count
       @usageTime += app.getTotalUsageTime

      @dau = app.getDailyActiveUsers(Date.today)
      @dau_delta += @dau - app.getDailyActiveUsers(Date.today - 1.days)
    end

    @formatted_dau_delta = format_delta(@dau_delta)
  end

  # Provides application specific information
  #  /apps/<id>
  def show
    @application = App.find(params[:id])
    @dau = @application.getDailyActiveUsers(Date.today)

    unless current_user.role? :admin
      if(@application.account.id != current_user.account.id)
        redirect_to '/'
      end
    end
  end


  # Provides Daily Action Users JSON for all applications to be displayed as a chart
  # using a client side charting framework
  def dau_data

    if current_user.role? :admin
      applications = App.all
    else
      applications = App.find_all_by_account_id(current_user.account.id)
    end

    result = AppDailySummary.select([:summary_date])
      .where(:app_id => applications)
      .group([:summary_date])
      .count(:dau_count)

    render :status => 200, :json => result

  end

  private

  # Helper function to format delta numbers with +/- and commas
  def format_delta(delta_number)
    result = number_with_delimiter(delta_number, :delimiter => ',')

    unless delta_number < 1
      result = '+' + result
    end
    return result
  end

end
