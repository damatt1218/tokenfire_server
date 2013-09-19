class AddCostToAchievementHistories < ActiveRecord::Migration
  def change
    add_column :achievement_histories, :cost, :float, :default => 0.0
  end
end
