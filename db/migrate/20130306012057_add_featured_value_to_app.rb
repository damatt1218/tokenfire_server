class AddFeaturedValueToApp < ActiveRecord::Migration
  def change
    add_column :apps, :featured_value, :integer, :default => 0
  end
end
