class AddDoorkeeperClientToApps < ActiveRecord::Migration
  def self.up
    change_table(:apps) do |t|
      t.string :uid
      t.string :secret
      t.string :redirect_uri



      # Uncomment below if timestamps were not included in your original model.
      # t.timestamps
    end

    add_index :apps, :uid, :unique => true
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
