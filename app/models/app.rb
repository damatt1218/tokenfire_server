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

  def self.setDoorClient
    puts 'Setting Doorclient model to App'
    # doesn't really do anything.   This method is here
    # because this class gets lazy loaded,  and doorkeeper doesn't get
    # this is a bug in doorkeeper
  end
end
