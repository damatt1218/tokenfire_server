class CreateAppUsages < ActiveRecord::Migration
  def change
    create_table :app_usages do |t|
      t.integer :account_id
      t.integer :app_id
      t.integer :usage_time
      t.integer :last_deducted_session_id

      t.timestamps
    end
  end
end
