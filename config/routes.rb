MobileRewardz::Application.routes.draw do

  use_doorkeeper do
    # it accepts :authorizations, :tokens, :applications and :authorized_applications
    controllers :applications => 'apps/custom_applications'
  end

  scope :module => "oauth" do

  end

  scope :module => 'apps' do
    match 'oauth/usage_info', :to => 'apps#getUsageInfo'
  end



devise_for :users, :controllers => { :registrations => "users/registrations", :sessions => "users/sessions" }
  #resources :users

  namespace :api do

    match 'app_usages/increment_time', :to => 'app_usages#incrementTimeSpent'
    match 'app_usages/get_usage', :to => 'app_usages#getUsageTime'
    match 'accounts/get_profile', :to => 'accounts#getProfile'
    match 'rewards/featured_rewards', :to => 'rewards#featured_rewards'
    match 'apps/featured_apps', :to => 'apps#featured_apps'

    resources :tokens, :only => [:create, :destroy]
    resources :rewards, :only => [:index, :show, :create, :update]
    resources :reward_histories, only: [:index, :show, :create, :update]
    resources :apps, :only => [:index, :show, :create, :update]
    resources :app_usages, :only => [:show, :create, :update]
    resources :accounts, :only => [:index, :show]
  end

  namespace :admin do
    match '/' => 'users#index'
    match 'rewards/pending_redeemed', :to => 'reward_histories#index'
    resources :users
    resources :reward_histories
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