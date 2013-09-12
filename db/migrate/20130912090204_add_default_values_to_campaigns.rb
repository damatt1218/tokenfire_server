class AddDefaultValuesToCampaigns < ActiveRecord::Migration
  def change
    change_column :campaigns, :active, :boolean, :default => false
    change_column :campaigns, :approved, :boolean, :default => false
  end
end
