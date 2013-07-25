class Device < ActiveRecord::Base
  attr_accessible :description, :uuid

  #relationships
  belongs_to :user
  has_many :achievement_histories
  has_many :app_sessions
  has_many :downloads

  def hasDownloadWithAppDownloadId(app_id)
    if (downloads.where(:app_download_id => app_id).length > 0)
      return true
    else
      return false
    end
  end

end
