class AddFeaturedValueToReward < ActiveRecord::Migration
  def change
    add_column :rewards, :featured_value, :integer, :default => 0
  end
end
