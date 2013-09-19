class AddAcceptedAndSubmittedToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :accepted, :boolean, :default => false
    add_column :campaigns, :submitted, :boolean, :default => false
  end
end
