module Api

  class AccountsController < ApplicationController
    doorkeeper_for :all
    respond_to :json, :xml

    # GET /api/accounts.json - Gets all accounts stored in the datasource
    def index
      @accounts = Account.all
      Rabl.render(@accounts, 'api/accounts/index', view_path: 'app/views')
    end

    # Get /api/accounts/1.json - Gets a single account based on the account_id
    def show
      @account = Account.find_by_id(params[:id])
      if (@account)
        Rabl.render(@account, 'api/accounts/show', view_path: 'app/views')
      else
        render status: 401, json: {error: "Invalid account"}
      end
    end

    # GET /api/accounts/get_profile - Gets profile for a user.  Currently just returns username and balance
    def getProfile
      account = current_user.account
      if account.nil?
        render status: 400, json: {error: "Invalid User"}
      else
        render status: 200, json: {username: current_user.username,
                                   email: current_user.email,
                                   firstName: current_user.first_name,
                                   lastName: current_user.last_name,
                                   company: current_user.company,
                                   balance: account.balance,
                                   registered: current_user.registered}
      end
    end

    private
    def current_user
      @current_user ||= User.find_by_id(doorkeeper_token.resource_owner_id)
    end
  end
end
