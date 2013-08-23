class ReferralCodeHistory < ActiveRecord::Base
  attr_accessible :referrer_id, :referree_value, :referrer_value

  # Relationships
  belongs_to :account
end
