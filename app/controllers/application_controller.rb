class ApplicationController < ActionController::Base
  protect_from_forgery

  def has_role?(current_user, role)
    if current_user == nil
      return false
    end
    return !!current_user.roles.find_by_name(role.to_s.camelize)
  end

  def after_sign_in_path_for(resource)
    oauth_applications_path

  end


  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    redirect_to root_url
  end
end
