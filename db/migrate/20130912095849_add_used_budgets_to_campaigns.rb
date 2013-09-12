class AddUsedBudgetsToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :overall_used_budget, :float, :default => 0.0
    add_column :campaigns, :daily_used_budget, :float, :default => 0.0
  end
end
