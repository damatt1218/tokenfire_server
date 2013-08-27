class OfferHistory < ActiveRecord::Base
  attr_accessible :amount, :company, :device_id, :transaction_id

  belongs_to :device

  # Functions
  def revenue
    return self.amount * 2 / 1000
  end
end
