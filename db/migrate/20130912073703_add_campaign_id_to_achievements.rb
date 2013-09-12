class AddCampaignIdToAchievements < ActiveRecord::Migration
  def change
    add_column :achievements, :campaign_id, :integer
  end
end
