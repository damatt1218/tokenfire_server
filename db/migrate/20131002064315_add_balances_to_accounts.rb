class AddBalancesToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :developer_balance, :float, :default => 0.0
    add_column :accounts, :developer_reserved_balance, :float, :default => 0.0
  end
end
