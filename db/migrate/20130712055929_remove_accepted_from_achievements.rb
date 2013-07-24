class RemoveAcceptedFromAchievements < ActiveRecord::Migration
  def up
    remove_column :achievements, :accepted
  end

end
