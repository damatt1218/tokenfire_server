class Reward < ActiveRecord::Base
  attr_accessible :cost, :description, :expiration, :image, :name, :quantity

  # Relationships
  has_many :reward_histories
  has_many :accounts, :through => :reward_histories
end
