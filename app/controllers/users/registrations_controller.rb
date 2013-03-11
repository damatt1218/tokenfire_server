class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :check_permissions, :only => [:cancel]
  skip_before_filter :require_no_authentication

  def check_permissions
    authorize! :create, resource
  end

  # POST /users
  # POST /users.json
  def create

    # Always set this role whenever anyone signs up (for now)
    if resource_params.has_key?("role_ids")
      resource_params.delete("role_ids")
      add_prospective_dev_role = true
    else
      add_prospective_dev_role = true
    end

    # Check to see if the android_id was passed in as one of the
    # parameters.  If it is, we need to create the new user
    # and assign the device that it was previously assigned to to
    # the new user
    if resource_params.has_key?("android_id")
      my_android_id = resource_params[:android_id]
      combine_accounts = true
      resource_params.delete("android_id")
    else
      combine_accounts = false
    end

    build_resource

    if add_prospective_dev_role
      resource.add_role_id(4)
    end
    if resource.save

      if combine_accounts
        resource.combine_accounts(my_android_id)
      end

      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

end