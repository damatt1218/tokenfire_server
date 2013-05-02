module Api

  # Controller for the Achievement History API
  # Enables devices to report achievement accomplishment
  class AchievementHistoriesController < ApplicationController

    # Require OAuth to access this controller
    doorkeeper_for :all

    # POST /api/achievements - Creates a new achievement history
    #   Expects JSON passed in this format:
    #     {
    #       "achievement_uid": The ID of the achievement to report
    #     }
    def report

      user = current_user
      app = current_application
      achievement = Achievement.find_by_uid(params["achievement_uid"])


      # Find the application
      # Find the achievement
      # Validate the achievement belongs to the application
      # Find/create the users device

      # Make sure the achievement is available to the user
      #  Has not achieved already, unless it is repeatable
      #  No special conditions to meet (still create a achievement history, but don't pay them)
      #  Is currently available

      # Create an achievement history
      # Save it

      # Add tokens to account

      # Parse the body of the POST as JSON
      parsed_json = JSON.parse(request.body.read)

      render status: 200, json:
          {
            a9t: parsed_json["achievement_uid"]
          }
    end

    private
    def current_user
      User.find_by_id(doorkeeper_token.resource_owner_id)
    end

    private
    def current_application
      App.find_by_id(doorkeeper_token.application_id)
    end

  end
end