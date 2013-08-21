class AddAmountToRewardHistory < ActiveRecord::Migration
  def change
    add_column :reward_histories, :amount, :integer, :default => 0
  end
end
