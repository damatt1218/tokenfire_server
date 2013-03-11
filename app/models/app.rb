class App < ActiveRecord::Base
  # Setup doorkeeper client extension
  doorkeeper_client!

  attr_accessible :name, :redirect_uri
  attr_accessible :description, :image, :name, :rating

  # relationships
  has_many :app_usages
  has_many :accounts, through: :app_usages
  belongs_to :account

  def getTotalUsageTime
    total_time = 0

    for app_usages in self.app_usages do
      total_time += app_usages.usage_time
    end

    return total_time
  end
end
