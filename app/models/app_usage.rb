class AppUsage < ActiveRecord::Base
  attr_accessible :account_id, :app_id, :usage_time
  after_initialize :init

  # Relationships
  belongs_to :account
  belongs_to :app

  has_many :app_sessions
  has_many :devices, through: :app_sessions


  def init
    self.usage_time ||= 0
  end

  def update_usage_from_sessions
    previous_usage_time = self.usage_time
    new_usage_time = app_sessions.sum(:session_duration) / 60

    if previous_usage_time < new_usage_time
      self.usage_time = new_usage_time
      self.save
      addCurrencyToAccount(self.account_id, new_usage_time - previous_usage_time)
    end
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