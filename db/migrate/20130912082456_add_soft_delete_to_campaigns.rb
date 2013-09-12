class AddSoftDeleteToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :soft_deleted, :boolean, :default => false
  end
end
