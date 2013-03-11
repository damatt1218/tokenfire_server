module Apps

  class AppsController < ApplicationController

    # returns the list of applications whose usage info will be displayed
    def getUsageInfo
      if (current_user.role? :admin)
        @applications = Doorkeeper.client.all
      elsif (current_user.role? :developer)
        @applications = Doorkeeper.client.find_all_by_account_id(current_user.account.id)
      end
    end

  end

end