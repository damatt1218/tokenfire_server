class CreateCampaignHistories < ActiveRecord::Migration
  def change
    create_table :campaign_histories do |t|
      t.integer :campaign_id
      t.integer :device_id

      t.timestamps
    end
  end
end
