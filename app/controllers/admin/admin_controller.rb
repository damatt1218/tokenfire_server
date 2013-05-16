module Admin

  class AdminController < ApplicationController
    before_filter :verify_admin

    def current_ability
      @current_ability ||= AdminAbility.new(current_user)
    end

    def verify_admin
      :authenticate_user!
      puts current_user
      redirect_to root_url unless has_role?(current_user, 'admin')
    end
  end

end
