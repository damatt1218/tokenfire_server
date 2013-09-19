class AddActualSpentToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :actual_overall_spent, :float, :default => 0.0
    add_column :campaigns, :actual_daily_spent, :float, :default => 0.0
  end
end
