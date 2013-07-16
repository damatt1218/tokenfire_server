class AddSoftDeletedToAchievements < ActiveRecord::Migration
  def change
    add_column :achievements, :soft_deleted, :boolean, :default => false
  end
end
