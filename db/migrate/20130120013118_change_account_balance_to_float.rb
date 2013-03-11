class ChangeAccountBalanceToFloat < ActiveRecord::Migration
  def up
    change_column :accounts, :balance, :float, :default => 0
  end

  def down
  end
end
