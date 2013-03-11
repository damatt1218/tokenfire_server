class AddUserIdToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :user_id, :integer
    add_index :devices, :user_id
  end
end
