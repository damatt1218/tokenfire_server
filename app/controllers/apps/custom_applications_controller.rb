module Apps

  class CustomApplicationsController < Doorkeeper::ApplicationsController

    # Show all Apps if the current user is admin. If the user's role is developer, only show the apps
    # that belong to that user.  Any other role will not be shown anything.
    def index
      @app = App.all
      if (current_user.role? :admin)
        @applications = Doorkeeper.client.all
      elsif (current_user.role? :developer)
        @applications = Doorkeeper.client.find_all_by_account_id(current_user.account.id)
      end

    end

    # This create function is limited to developers and admins roles only.
    def create
      @application  = App.new(params[:application])

      @application.account = current_user.account

      if @application.save
        redirect_to apps_url, :notice => t('doorkeeper.flash.applications.create.notice')
      else
        render :new
      end
    end

  end

end
