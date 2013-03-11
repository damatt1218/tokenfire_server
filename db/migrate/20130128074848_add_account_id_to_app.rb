class AddAccountIdToApp < ActiveRecord::Migration
  def change
    add_column :apps, :account_id, :integer
    add_index :apps, :account_id
  end
end
