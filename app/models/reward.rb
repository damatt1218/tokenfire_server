class Reward < ActiveRecord::Base
  attr_accessible :name, :description, :cost, :quantity, :expiration, :image, :featured_value, :as => :admin

  # Scopes
  # Featured rewards ordered least to greatest
  scope :featured, where("featured_value > ?", 0).order("featured_value ASC")

  # Relationships
  has_many :reward_histories
  has_many :accounts, :through => :reward_histories
end
