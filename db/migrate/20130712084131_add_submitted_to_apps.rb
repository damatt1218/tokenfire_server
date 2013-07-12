class AddSubmittedToApps < ActiveRecord::Migration
  def change
    add_column :apps, :submitted, :boolean, :default => false
  end
end
