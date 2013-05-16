class Users::SessionsController < Devise::SessionsController

  # GET /resource/sign_in
  def new
    session[:return_to] = params[:return_to] if params[:return_to]

    self.resource = build_resource(nil, :unsafe => true)
    clean_up_passwords(resource)
    respond_with(resource, serialize_options(resource))
  end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)

    if resource_params.has_key?("android_id")
      resource.combine_accounts(resource_params[:android_id])
      render status: 201, json: {success: "Registered!"}
    else
      if session[:return_to]
        redirect_to session[:return_to]
        session[:return_to] = nil
      else
        respond_with resource, :location => after_sign_in_path_for(resource)
      end
    end


  end

end
