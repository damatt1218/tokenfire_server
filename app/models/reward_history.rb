class RewardHistory < ActiveRecord::Base
  attr_accessible :account_id, :reward_id, :redemption_code, :processed

  # Relationships
  belongs_to :account
  belongs_to :reward
end
