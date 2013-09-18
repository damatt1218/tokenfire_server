class CampaignsController < ApplicationController

  CAMPAIGN_DURATION_DAYS = 3

  # Index to view all campaigns for an application
  # GET /apps/:app_id/campaigns
  #   :app_id is the id of the app to view campaigns for
  def index
    # Redirect if the user doesn't have access
    if !hasAccess
      redirect_to '/'
    end

    @campaigns = Campaign.find_all_by_app_id(params[:app_id])

  end

  # Gets data for new campaign view
  # GET /apps/:app_id/campaigns/new
  #   :app_id is the id of the app the campaign will be associated with
  def new
    # Redirect if the user doesn't have access
    if !hasAccess
      render :file => "public/401.html", :status => :unauthorized
    end

    # Get a new campaign and set the app_id
    @campaign = Campaign.new
    @campaign.app_id = params[:app_id]
  end

  # Creates a new campaign
  # POST /apps/:app_id/campaigns
  #   :app_id is the id of the app the campaign will be associated with
  def create
    # Check if user has access
    if hasAccess

      # Create the achievement form the input and set the app id
      @campaign = Campaign.new(params[:campaign])
      @campaign.app_id = params[:app_id]

      if (@campaign.duration.nil?)
        @campaign.duration = CAMPAIGN_DURATION_DAYS
      end

      # Save the new campaign
      if @campaign.save
        redirect_to app_campaign_url(params[:app_id], @campaign), :flash => { :notice => "Campaign successfully created." }
      else
        render :new
      end
    end
  end

  # Updates an existing campaign
  # PUT /apps/:app_id/campaigns/:id
  #   :app_id is the id of the app the campaign will be associated with
  #   :id is the id of the campaign to update
  def update
    # Check if user has access
    if hasAccess
      # Do the update
      if @campaign.update_attributes(params[:campaign])
        if (@campaign.duration.nil?)
          @campaign.duration = CAMPAIGN_DURATION_DAYS
        end
        redirect_to app_campaign_url(params[:app_id], @campaign), :flash => { :notice => "Campaign successfully updated." }
      else
        render :edit
      end
    end
  end

  # Shows a single campaign
  #   GET /apps/:app_id/campaigns/:id
  #     :app_id is the id of the app the campaign will be associated with
  #     :id is the id of the campaign to view
  def show
    # Redirect if the user doesn't have access
    if !hasAccess
      redirect_to '/'
    end
    @downloads_count = Download.where(:app_download_id  => @application.id,
                                      :pending => false).count
  end

  # Edit a campaign
  #   GET /apps/:app_id/campaigns/:id/edit
  #     :app_id is the id of the app the campaign will be associated with
  #     :id is the id of the campaign to edit
  def edit
    # Redirect if the user doesn't have access
    if !hasAccess
      redirect_to '/'
    end
  end

  # Soft deletes an existing campaign
  # /apps/:app_id/campaigns/:id/soft_delete
  #   :app_id is the id of the app the campaign will be associated with
  #   :id is the id of the campaign to update
  def softDelete
    if hasAccess
      campaign = Campaign.find(params[:id])
      campaign.soft_deleted = true;
      campaign.save
      redirect_to app_campaigns_url, :flash => { :notice => "Campaign successfully deleted." }
    else
      redirect_to '/'
    end

  end

  # Restores a soft deleted, existing campaign
  # /apps/:app_id/campaigns/:id/restore
  #   :app_id is the id of the app the campaign will be associated with
  #   :id is the id of the campaign to update
  def restore
    if isAdmin && hasAccess
      campaign = Campaign.find(params[:id])
      campaign.soft_deleted = false;
      campaign.save
      redirect_to app_path(params[:app_id]), :flash => { :notice => "Campaign successfully restored." }
    else
      redirect_to '/'
    end

  end

  # Activates a campaign
  # /apps/:app_id/campaigns/:id/activate
  #   :app_id is the id of the app the campaign will be associated with
  #   :id is the id of the campaign to activate
  def activate
    if hasAccess
      Campaign.find_all_by_app_id(@application.id).each do |c|
        c.active = false
        c.save
      end

      @campaign.active = true
      @campaign.save
      redirect_to app_campaigns_path(params[:app_id]), :flash => { :notice => "Campaign successfully activated." }
    else
      redirect_to '/'
    end

  end


  # Deactivates a campaign
  # /apps/:app_id/campaigns/:id/deactivate
  #   :app_id is the id of the app the campaign will be associated with
  #   :id is the id of the campaign to deactivate
  def deactivate
    if hasAccess
      @campaign.active = false
      @campaign.save
      redirect_to app_path(params[:app_id]), :flash => { :notice => "Campaign successfully deactivated." }
    else
      redirect_to '/'
    end

  end


  # Checks permissions to see if the requesting user has access to the data requested
  # If the user has access:
  #   - The @application field will be populated (if the :app_id parameter is available)
  #   - The @campaign field will be populated (if the :id parameter is available)
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

    # If there is no campaign id to verify then we are done
    if (params[:id] == nil)
      return true
    end

    # Find the campaign being requested
    begin
      @campaign = Campaign.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      @application = nil
      @campaign = nil
      return false
    end

    # Verify the campaign is associated with the app (which we already verified access to)
    if (@campaign.app_id != @application.id) && (!isAdmin)
      @application = nil
      @campaign = nil
      return false
    end

    return true
  end

  # Returns true if the current user has the admin role
  private
  def isAdmin
    if current_user == nil
      return false
    else
      return (current_user.role? :admin)
    end
  end

  # Returns true if the current user has the developer role
  private
  def isDev
    if current_user == nil
      return false
    else
      return (current_user.role? :developer)
    end
  end
end
