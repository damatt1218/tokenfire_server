require 'securerandom'

class Account < ActiveRecord::Base
  attr_accessible :balance, :referral_code

  #relationships
  belongs_to :user
  has_many :reward_histories
  has_many :rewards, :through => :reward_histories
  has_many :app_usages
  has_many :apps
  has_many :promo_code_histories
  has_many :promo_codes, :through => :promo_code_histories
  has_one :referral_code_history

  after_create :generate_referral_code

  def generate_referral_code (length = 6)
    test_val = true
    if self.user.registered == true
      while test_val
        temp_code = SecureRandom.urlsafe_base64 length
        if !Account.exists?(:referral_code => temp_code)
          test_val = false
          self.referral_code = temp_code
          self.save
        end
      end
    end
  end

  def add_to_balance(amount)
    if self.balance.nil?
      self.balance = amount
    else
      self.balance += amount
    end
    self.save
  end

end
