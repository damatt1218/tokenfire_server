class AddApkToApps < ActiveRecord::Migration
  def change
    add_column :apps, :apk, :string
  end
end
