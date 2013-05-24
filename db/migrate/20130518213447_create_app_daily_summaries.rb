class CreateAppDailySummaries < ActiveRecord::Migration
  def change
    create_table :app_daily_summaries do |t|
      t.integer :app_id
      t.date :summary_date
      t.integer :dau_count
      t.integer :session_count
      t.integer :device_count
      t.integer :total_duration
      t.integer :average_duration


      t.timestamps
    end
  end
end
