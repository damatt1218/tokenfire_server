class CreateDownloads < ActiveRecord::Migration
  def change
    create_table :downloads do |t|
      t.integer :device_id
      t.integer :app_id
      t.boolean :pending
      t.datetime :link_click_time
      t.datetime :initial_launch_time
      t.timestamps
    end
  end
end
