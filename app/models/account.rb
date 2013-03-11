class Account < ActiveRecord::Base
  attr_accessible :balance

  #relationships
  belongs_to :user
  has_many :reward_histories
  has_many :rewards, :through => :reward_histories
  has_many :app_usages
  has_many :apps

end
