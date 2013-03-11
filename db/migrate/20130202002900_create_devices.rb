class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :uuid
      t.text :description

      t.timestamps
    end

    add_index :devices, :uuid, :unique => true
  end
end
