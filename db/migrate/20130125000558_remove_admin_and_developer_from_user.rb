class RemoveAdminAndDeveloperFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :admin
    remove_column :users, :developer
  end

  def down
  end
end
