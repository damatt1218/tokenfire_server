class CampaignHistory < ActiveRecord::Base
  attr_accessible :campaign_id, :device_id

  # Relationships
  has_one :campaign
  belongs_to :device
end
