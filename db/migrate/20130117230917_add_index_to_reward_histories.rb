class AddIndexToRewardHistories < ActiveRecord::Migration
  def change
    add_index :reward_histories, [:account_id, :reward_id]
  end
end
