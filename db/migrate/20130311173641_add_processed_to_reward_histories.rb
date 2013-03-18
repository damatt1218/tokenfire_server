class AddProcessedToRewardHistories < ActiveRecord::Migration
  def change
    add_column :reward_histories, :processed, :boolean, :default => false
  end
end
