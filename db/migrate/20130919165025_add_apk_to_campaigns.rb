class AddApkToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :apk, :string
  end
end
