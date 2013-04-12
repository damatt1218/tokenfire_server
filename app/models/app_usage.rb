class AppUsage < ActiveRecord::Base
  attr_accessible :account_id, :app_id, :usage_time
  after_initialize :init

  # Relationships
  belongs_to :account
  belongs_to :app

  has_many :app_session_histories

  def init
    self.usage_time ||= 0
  end

  # Method to set the currency in a user's account based on the usage time
  # Conversion takes place here.  Will want to adjust this later.
  def addCurrencyToAccount(account_id, usage_time)
    account = Account.find_by_id(account_id)
    balance = 0.0
    if account
      if (account.balance.nil?)
        balance = (usage_time / 3600.0)
      else
        balance = account.balance
        balance += (usage_time / 3600.0)
      end

      account.balance = balance
      account.save
    end
  end

end