class AddIndexToAppUsage < ActiveRecord::Migration
  def change
    add_index :app_usages, [:account_id, :app_id]
  end
end
