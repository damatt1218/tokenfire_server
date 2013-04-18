class CreateAppSessionHistories < ActiveRecord::Migration
  def change
    create_table :app_session_histories do |t|
      t.string :session_id
      t.string :sdkVersion
      t.datetime :eventTimeStamp
      t.integer :SessionDuration

      t.timestamps
    end
  end
end
