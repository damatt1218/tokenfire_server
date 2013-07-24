class AddUrlAndDisabledToApps < ActiveRecord::Migration
  def change
    add_column :apps, :url, :string
    add_column :apps, :disabled, :boolean, :default => false
  end
end
