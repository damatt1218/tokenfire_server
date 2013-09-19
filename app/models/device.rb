class Device < ActiveRecord::Base
  attr_accessible :description, :uuid, :gcm_id

  #relationships
  belongs_to :user
  has_many :achievement_histories
  has_many :app_sessions
  has_many :downloads
  has_many :campaign_histories

  def hasDownloadWithAppDownloadId(app_id)
    if (downloads.where(:app_download_id => app_id).length > 0)
      return true
    else
      return false
    end
  end

  def getCampaignWithAppId(app_id)
    campaign_histories.each do |c|
      if c.campaign.app_id == app_id
        return c.campaign
      end
    end
    return nil
  end

  def getCampaignHistoryWithAppId(app_id)
    campaign_histories.each do |c|
      if c.campaign.app_id == app_id
        return c
      end
    end
    return nil
  end

end
