class AchievementsController < ApplicationController

  # Index to view all achievements for an application
  # GET /apps/:app_id/achievements
  #   :app_id is the id of the app to view achievements for
  def index
    # Redirect if the user doesn't have access
    if !hasAccess
      redirect_to '/'
    end
  end

  # Gets data for new achievement view
  # GET /apps/:app_id/achievements/new
  #   :app_id is the id of the app the achievement will be associated with
  def new
    # Redirect if the user doesn't have access
    if !hasAccess
      redirect_to '/'
    end

    # Get a new achievement and set the app_id
    @achievement = Achievement.new
    @achievement.app_id = params[:app_id]
  end

  # Creates a new achievement
  # POST /apps/:app_id/achievements
  #   :app_id is the id of the app the achievement will be associated with
  def create
    # Check if user has access
    if hasAccess

      # Create the achievement form the input and set the app id
      @achievement = Achievement.new(params[:achievement])
      @achievement.app_id = params[:app_id]

      # Save the new achievement
      if @achievement.save
        redirect_to app_achievements_url params[:app_id]
      end
    end
  end

  # Updates an existing achievement
  # PUT /apps/:app_id/achievements/:id
  #   :app_id is the id of the app the achievement will be associated with
  #   :id is the id of the achievement to update
  def update
    # Check if user has access
    if hasAccess
      # Do the update
      if @achievement.update_attributes(params[:achievement])
        redirect_to app_achievement_url params[:app_id]
      end
    end
  end

  # Shows a single achievement
  #   GET /apps/:app_id/achievements/:id
  #     :app_id is the id of the app the achievement will be associated with
  #     :id is the id of the achievement to view
  def show
    # Redirect if the user doesn't have access
    if !hasAccess
      redirect_to '/'
    end
  end

  # Edit an achievement
  #   GET /apps/:app_id/achievements/:id/edit
  #     :app_id is the id of the app the achievement will be associated with
  #     :id is the id of the achievement to edit
  def edit
    # Redirect if the user doesn't have access
    if !hasAccess
      redirect_to '/'
    end
  end

  # Soft deletes an existing achievement
  # /apps/:app_id/achievements/:id/soft_delete
  #   :app_id is the id of the app the achievement will be associated with
  #   :id is the id of the achievement to update
  def softDelete
    if hasAccess
      achievement = Achievement.find(params[:id])
      achievement.soft_deleted = true;
      achievement.save
      redirect_to app_path(params[:app_id])
    else
      redirect_to '/'
    end

  end

  # Restores a soft deleted, existing achievement
  # /apps/:app_id/achievements/:id/restore
  #   :app_id is the id of the app the achievement will be associated with
  #   :id is the id of the achievement to update
  def restore
    if isAdmin && hasAccess
      achievement = Achievement.find(params[:id])
      achievement.soft_deleted = false;
      achievement.save
      redirect_to app_path(params[:app_id])
    else
      redirect_to '/'
    end

  end

  # Checks permissions to see if the requesting user has access to the data requested
  # If the user has access:
  #   - The @application field will be populated (if the :app_id parameter is available)
  #   - The @achievement field will be populated (if the :id parameter is available)
  private
  def hasAccess

    # User must be a dev or admin to access this data
    if (!isDev) && (!isAdmin)
      return false
    end

    # Find the application being requested
    begin
      @application = App.find(params[:app_id])
    rescue ActiveRecord::RecordNotFound
      @application = nil
      return false
    end

    # Dev user account can only see apps associated to their account
    if (current_user.account.id != @application.account.id) && (!isAdmin)
      @application = nil
      return false
    end

    # If there is no achievement id to verify then we are done
    if (params[:id] == nil)
      return true
    end

    # Find the achievement being requested
    begin
      @achievement = Achievement.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      @application = nil
      @achievement = nil
      return false
    end

    # Verify the achievement is associated with the app (which we already verified access to)
    if (@achievement.app_id != @application.id) && (!isAdmin)
      @application = nil
      @achievement = nil
      return false
    end

    return true
  end

  # Returns true if the current user has the admin role
  private
  def isAdmin
    return (current_user.role? :admin)
  end

  # Returns true if the current user has the developer role
  private
  def isDev
    return (current_user.role? :developer)
  end

end
