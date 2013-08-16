class AddGcmIdToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :gcm_id, :string
  end
end
