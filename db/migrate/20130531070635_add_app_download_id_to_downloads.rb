class AddAppDownloadIdToDownloads < ActiveRecord::Migration
  def change
    add_column :downloads, :app_download_id, :integer
  end
end
