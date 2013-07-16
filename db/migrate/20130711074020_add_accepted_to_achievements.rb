class AddAcceptedToAchievements < ActiveRecord::Migration
  def change
    add_column :achievements, :accepted, :boolean, :default => false
  end
end
