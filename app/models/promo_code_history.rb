class PromoCodeHistory < ActiveRecord::Base
  attr_accessible :value, :promo_code_id, :account_id

  # Relationships
  belongs_to :promo_code
  belongs_to :account
end
