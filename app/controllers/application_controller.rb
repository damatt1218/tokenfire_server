class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :error_messages

  def has_role?(current_user, role)
    if current_user == nil
      return false
    end
    return !!current_user.roles.find_by_name(role.to_s.camelize)
  end

  def after_sign_in_path_for(resource)
    apps_path
  end

  class UserHistory
    attr_accessor :name, :description, :image, :amount, :date

    def populate(history_name, history_description, history_image, history_amount, history_date)
      self.name = history_name
      self.description = history_description
      self.image = history_image
      self.amount = history_amount
      self.date = history_date
    end

  end


  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    redirect_to root_url
  end
end
