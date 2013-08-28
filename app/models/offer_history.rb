class OfferHistory < ActiveRecord::Base
  attr_accessible :amount, :company, :device_id, :transaction_id

  belongs_to :device

end
