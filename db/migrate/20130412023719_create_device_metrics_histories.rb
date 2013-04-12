class CreateDeviceMetricsHistories < ActiveRecord::Migration
  def change
    create_table :device_metrics_histories do |t|
      t.string :OS
      t.string :OS_version
      t.string :Device_Type
      t.string :Resolution
      t.string :Carrier
      t.string :AppVersion
      t.string :Location

      t.timestamps
    end
  end
end
