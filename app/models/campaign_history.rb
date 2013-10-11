class CampaignHistory < ActiveRecord::Base
  attr_accessible :campaign_id, :device_id

  # Relationships
  has_one :campaign
  belongs_to :device

  def getAchievementHistories
    histories = Array.new
    campaign.achievements.each do |a|
      a.achievment_histories.each do |ah|
        if ah.device_id == device_id
          histories << ah
        end
      end
    end

    return histories
  end
end
