module Admin
  class AppsController < AdminController
    include ActionView::Helpers::NumberHelper
    # Provides controller to help display all the apps associated with th current
    # user and a summary of statistics
    #  /apps
    def index
        @applications = App.all
        @accepted_applications = App.active
        @submitted_applications = App.submitted
        @pending_applications = App.pending
        @deleted_applications = App.deleted
    end

    # Provides application specific information
    #  /apps/<id>
    def show
      @application = App.find(params[:id])
      @dau = @application.getDailyActiveUsers(Date.today)
      @downloads_count = Download.where(:app_download_id  => @application.id,
                                        :pending => false).count
      @mau = @application.getMonthlyActiveUsers(Date.today)
    end

    def edit
      @application = App.find(params[:id])
    end

    def update
      @application = App.find(params[:id])

      if @application.update_attributes(params[:application], :as => :admin)
        redirect_to admin_apps_path, :notice => 'App was successfully updated.'
      else
        render :action => "edit", :error => 'Could not update app.'
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
      if (@application.account_id == current_user.account.id) || (current_user.role? :admin)
        @application.submitted = true
        @application.save
      end

      redirect_to apps_path
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
  end
end
