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

  def update_usage_from_sessions
    historyseconds = app_session_histories.where("sessionduration > 0").group("session_id").maximum("sessionduration")

    previousUsageTime = self.usage_time
    self.usage_time = 0

    historyseconds.each { |minutes|
      self.usage_time += minutes[1] / 60
    }
    self.save

    addCurrencyToAccount(self.account_id, self.usage_time - previousUsageTime) if previousUsageTime < self.usage_time
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


  def self.find_or_create_by_app_id_and_user_id(app_id, user_id)

    userAccount = Account.find_by_user_id(user_id)

    newUsage = AppUsage.where(:app_id => app_id, :account_id => userAccount.id).first_or_create()


    return newUsage
  end

end