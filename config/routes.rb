MobileRewardz::Application.routes.draw do

  # Support Pages
  match 'about', :to => 'support#about_us'
  match 'support', :to => 'support#home'
  match 'contact', :to => 'support#contact_us'
  match 'terms', :to => 'support#dev_terms'
  match 'privacy', :to => 'support#privacy'
  match 'usertos', :to => 'support#end_user_tos'
  # Using GitHub documentation for now
  # get 'support/android_sdk_setup'

  use_doorkeeper

  resources :device_metrics_histories

  resources :app_session_histories

  use_doorkeeper do
    # it accepts :authorizations, :tokens, :applications and :authorized_applications
    controllers :applications => 'apps/custom_applications'
  end

  match 'apps/dau_data', :to => 'apps#dau_data', :via => :get
  match 'apps/disable/:id', :to => 'apps#disable', :via => :get, :as => :apps_disable
  match 'apps/restore/:id', :to => 'apps#restore', :via => :get, :as => :apps_restore
  match 'apps/accept/:id', :to => 'apps#accept', :via => :get, :as => :apps_accept
  match 'apps/submit/:id', :to => 'apps#submit', :as => :apps_submit
  resources :apps do
    match 'achievements/:id/soft_delete', :to => 'achievements#softDelete', :as => :soft_delete_app_achievement
    match 'achievements/:id/restore', :to => 'achievements#restore', :as => :restore_app_achievement
    resources :achievements
  end

  scope :module => "oauth" do

  end

  scope :module => 'apps' do
    match 'oauth/usage_info', :to => 'apps#getUsageInfo'
    match 'create_app', :to=> 'custom_applications#create'
  end

  devise_for :users, :controllers => {:registrations => "users/registrations", :sessions => "users/sessions"}
  #resources :users

  # Routing for API
  namespace :api do
    match 'client_api/validate_app_id', :to => 'client_sdk_api#validate_app_id'
    match 'client_api/post_session_history', :to => 'client_sdk_api#post_session_history'
    match 'app_usages/increment_time', :to => 'app_usages#incrementTimeSpent'
    match 'app_usages/get_usage', :to => 'app_usages#getUsageTime'
    match 'accounts/adColony_Video_Complete', :to => 'accounts#adcolonyVideoComplete'
    match 'accounts/get_profile', :to => 'accounts#getProfile'
    match 'accounts/update_profile', :to => 'accounts#updateProfile'
    match 'accounts/unregister_device', :to => 'accounts#unregisterDevice'
    match 'accounts/get_histories', :to => 'accounts#getHistories'
    match 'accounts/set_registration_id', :to => 'accounts#setRegistrationId'
    match 'accounts/tapjoy_offer_complete', :to => 'accounts#tapjoyOfferComplete'
    match 'accounts/sponsorpay_offer_complete', :to => 'accounts#sponsorPayOfferComplete'
    match 'accounts/aarki_offer_complete', :to => 'accounts#aarkiOfferComplete'
    match 'accounts/metaps_offer_complete', :to => 'accounts#metapsOfferComplete'
    match 'rewards/featured_rewards', :to => 'rewards#featured_rewards'
    match 'apps/featured_apps', :to => 'apps#featured_apps'
    match 'achievements/report', :to => 'achievement_histories#report', :via => :post
    match 'achievements/status', :to => 'achievement_histories#status', :via => :get
    match 'downloads/initial_app_launch', :to => 'downloads#initial_app_launch'
    match 'downloads/clicked_download_app', :to => 'downloads#clicked_download_app'
    match 'promo_codes/apply_promo_code', :to => 'promo_codes#applyPromoCode'

    resources :tokens, :only => [:create, :destroy]
    resources :rewards, :only => [:index, :show, :create, :update]
    resources :reward_histories, only: [:index, :show, :create, :update]
    resources :apps, :only => [:index, :show, :create, :update]
    resources :app_usages, :only => [:show, :create, :update]
    resources :accounts, :only => [:index, :show]
  end

  # Admin routes
  namespace :admin do
    resources :rewards
    resources :promo_codes
    resources :users
    resources :reward_histories
    match 'currency', :to => 'dashboard#currency'
    match 'rewards/pending_redeemed', :to => 'reward_histories#index'
  end


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (apps/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  root :to => 'static_pages#home'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
