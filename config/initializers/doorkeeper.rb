Doorkeeper.configure do
  # Change the ORM that doorkeeper will use.
  # Currently supported options are :active_record, :mongoid, :mongo_mapper
  orm :active_record

  # This block will be called to check whether the resource owner is authenticated or not.
  resource_owner_authenticator do
    if current_user == nil
      puts "********************in doorkeeper.rb********************"
      puts request.path_parameters
      puts request.query_parameters
      puts "********************************************************"
      if params.has_key?(:android_id)
        puts "HERE: " + params[:android_id]
        User.find_create_by_android_id(params[:android_id])
      else
        puts "****** params has no android_id *******"
        redirect_to(new_user_session_url(return_to: request.fullpath))
      end
    else
      puts "*********** current_user is not nil *********"
      User.find_by_email(current_user.email) || redirect_to(new_user_session_url(return_to: request.fullpath))
    end
    #raise "Please configure doorkeeper resource_owner_authenticator block located in #{__FILE__}"
    # Put your resource owner authentication logic here.
    # Example implementation:

  end

  resource_owner_from_credentials do |routes|
    #u = User.find_for_database_authentication(:username => params[:username])
    if params.has_key?(:android_id)
      u = User.find_create_by_android_id(params[:android_id])
    end


    if u.password_required? && !(params.has_key?(:android_id))
      u if u && u.valid_password?(params[:password])
    else
      u if u
    end

  end

  # If you want to restrict access to the web interface for adding oauth authorized applications, you need to declare the block below.
  admin_authenticator do
  #   # Put your admin authentication logic here.
  #   # Example implementation:
  #  Admin.find_by_id(session[:admin_id]) || redirect_to(new_admin_session_url)
    puts "***************** IN admin_authenticator ***************"
    if ((current_user.role? :admin) || (current_user.role? :developer))
      User.find_by_email(current_user.email) || redirect_to(root_url)
    else
      redirect_to(root_url)
    end
  end

  # Authorization Code expiration time (default 10 minutes).
  # authorization_code_expires_in 10.minutes

  # Access token expiration time (default 2 hours).
  # If you want to disable expiration, set this to nil.
  # access_token_expires_in 2.hours

  # Issue access tokens with refresh token (disabled by default)
  # use_refresh_token

  # Define access token scopes for your provider
  # For more information go to https://github.com/applicake/doorkeeper/wiki/Using-Scopes
  # default_scopes  :public
  # optional_scopes :write, :update

  # Change the way client credentials are retrieved from the request object.
  # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
  # falls back to the `:client_id` and `:client_secret` params from the `params` object.
  # Check out the wiki for more information on customization
  # client_credentials :from_basic, :from_params

  # Change the way access token is authenticated from the request object.
  # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
  # falls back to the `:access_token` or `:bearer_token` params from the `params` object.
  # Check out the wiki for mor information on customization
  # access_token_methods :from_bearer_authorization, :from_access_token_param, :from_bearer_param

  # Change the test redirect uri for client apps
  # When clients register with the following redirect uri, they won't be redirected to any server and the authorization code will be displayed within the provider
  # The value can be any string. Use nil to disable this feature. When disabled, clients must provide a valid URL
  # (Similar behaviour: https://developers.google.com/accounts/docs/OAuth2InstalledApp#choosingredirecturi)
  #
  # test_redirect_uri 'urn:ietf:wg:oauth:2.0:oob'

  # Under some circumstances you might want to have applications auto-approved,
  # so that the user skips the authorization step.
  # For example if dealing with trusted a application.
  # skip_authorization do |resource_owner, client|
  #   client.superapp? or resource_owner.admin?
  # end
end
