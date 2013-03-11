class CreateRewardHistories < ActiveRecord::Migration
  def change
    create_table :reward_histories do |t|
      t.integer :account_id
      t.integer :reward_id

      t.timestamps
    end
  end
end
