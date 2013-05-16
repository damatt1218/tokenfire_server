class CreateAppSessions < ActiveRecord::Migration
  def change
    create_table :app_sessions do |t|
      t.string :reported_session_id
      t.datetime :session_start
      t.integer :session_duration
      t.string :sdk_version

      t.integer :device_id
      t.integer :app_usage_id

      t.timestamps
    end
  end
end
