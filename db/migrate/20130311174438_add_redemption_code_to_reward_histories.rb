class AddRedemptionCodeToRewardHistories < ActiveRecord::Migration
  def change
    add_column :reward_histories, :redemption_code, :string
  end
end
