class AppsController < ApplicationController
  include ActionView::Helpers::NumberHelper

  # Provides controller to help display all the apps associated with the current
  # user and a summary of statistics
  #  /apps
  def index
    @applications = App.where(:account_id => current_user.account.id, :disabled => false)
    @accepted_applications = App.where(:account_id => current_user.account.id).active
    # @pending_applications = App.where(:account_id => current_user.account.id,
    #                                   :accepted => false,
    #                                   :submitted => false,
    #                                   :disabled => false)
    # @submitted_applications = App.where(:account_id => current_user.account.id,
    #                                     :submitted => true,
    #                                     :accepted => false,
    #                                     :disabled => false)

    # This should be pre-calculate when we start to get a real amount of data
    # @users = 0
    # @usageTime = 0
    # @dau = 0
    # @dau_delta = 0
    # @mau = 0
    # @formatted_dau_delta = '0'
    # @downloads = 0

    # @accepted_applications.each do |app|
    #    @users += app.accounts.count
    #    @usageTime += app.getTotalUsageTime

    #   @mau += app.getMonthlyActiveUsers(Date.today)
    #   @dau += app.getDailyActiveUsers(Date.today)
    #   @dau_delta += @dau - app.getDailyActiveUsers(Date.today - 1.days)
    #   @downloads += Download.where(:app_download_id  => app.id,
    #                               :pending => false).count
    # end

    # @formatted_dau_delta = format_delta(@dau_delta)
  end

  # Provides application specific information
  #  /apps/<id>
  def show
    @application = App.find(params[:id])
    @dau = @application.getDailyActiveUsers(Date.today)
    @downloads_count = Download.where(:app_download_id  => @application.id,
                                      :pending => false).count
    @mau = @application.getMonthlyActiveUsers(Date.today)
    @dau_data = getDaus(@application, Date.today - 7.days, 7)
    @mau_data = getMaus(@application, Date.today - 12.months, 12)


    unless current_user.role? :admin
      if(@application.account.id != current_user.account.id)
        redirect_to '/'
      end
    end
  end


  def quickstart
    @applications = App.where(:account_id => current_user.account.id, :disabled => false)
    @accepted_applications = App.where(:account_id => current_user.account.id).active
    @selected_app = nil
    if params.has_key?(:appid)
      @selected_app = App.find(params[:appid])
    end
  end

  # Allows "soft deletion" of apps instead of destroying the object altogether
  # /apps/disable/<id>
  def disable
    @application = App.find(params[:id])
    if (@application.account_id == current_user.account.id) || (current_user.role? :admin)
      @application.disabled = true
      @application.save
    end

    redirect_to apps_path
  end

  # Allows admins to restore "soft deleted" apps
  # /apps/restore/<id>
  def restore
    @application = App.find(params[:id])
    if current_user.role? :admin
      @application.disabled = false
      @application.save
    end

    redirect_to apps_path
  end

  # Allows admins to accept apps
  # /apps/accept/<id>
  def accept
    @application = App.find(params[:id])
    if current_user.role? :admin
      @application.accepted = true
      @application.save
    end

    redirect_to apps_path
  end

  # Submits apps for review
  # /apps/submit/<id>
  def submit
    @application = App.find(params[:id])
    if @application[:apk].nil?
      redirect_to edit_oauth_application_path(params[:id]), :flash => { :notice => "Application not submitted. Missing Apk!" }
    else
      if (@application.account_id == current_user.account.id) || (current_user.role? :admin)
        @application.submitted = true
        @application.save
      end

      redirect_to app_path(params[:id]), :flash => { :notice => "Application successfully submitted." }
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
      .sum(:dau_count)


    # annoying,  but an OrderedHash doesn't show up as an object array in json,
    # so we have to convert it.
    result_array = Array.new

    result.each do |key|
      internal_hash = Hash.new
      internal_hash['report_date'] = key[0]
      internal_hash['user_count'] = key[1]
      result_array.push(internal_hash)
    end


    render :status => 200, :json => result_array

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

  def getDaus(app, startDate, days)
    if app.nil? || startDate.nil? || days.nil?
      return nil
    end

    result_array = Array.new
    (0..(days-1)).each do |i|
      result_array << [startDate + i.days, app.getDailyActiveUsers(startDate + i.days)]
    end

    return result_array
  end

  def getMaus(app, startDate, months)
    if app.nil? || startDate.nil? || months.nil?
      return nil
    end

    result_array = Array.new
    (0..(months-1)).each do |i|
      result_array << [(startDate + i.months).strftime("%B %Y"), app.getMonthlyActiveUsers(startDate + i.months)]
    end

    return result_array
  end

end
