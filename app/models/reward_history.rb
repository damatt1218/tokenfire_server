class RewardHistory < ActiveRecord::Base
  attr_accessible :account_id, :reward_id

  # Relationships
  belongs_to :account
  belongs_to :reward
end
