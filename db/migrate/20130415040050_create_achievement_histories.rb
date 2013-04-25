class CreateAchievementHistories < ActiveRecord::Migration
  def change
    create_table :achievement_histories do |t|
      t.datetime :acquired
      t.integer :value
      t.integer :device_id

      t.timestamps
    end
  end
end
