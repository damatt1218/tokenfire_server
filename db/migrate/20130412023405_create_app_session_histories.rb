class CreateAppSessionHistories < ActiveRecord::Migration
  def change
    create_table :app_session_histories do |t|
      t.string :app_session_id
      t.datetime :event_timestamp
      t.integer :reported_duration
      t.integer :event_type

      t.timestamps
    end
  end
end
