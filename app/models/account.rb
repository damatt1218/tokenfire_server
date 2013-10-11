require 'securerandom'

class Account < ActiveRecord::Base
  attr_accessible :balance, :referral_code, :developer_reserved_balance, :developer_balance

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

  # check to make sure there is enough remaining budget based on a passed in cost
  def hasRemainingDevBalance(cost)
    if (cost < (developer_balance - developer_reserved_balance))
      return true
    else
      return false
    end
  end

  def getCumulativeCampaignBudget
    budget_total = 0.0
    apps.each do |a|
      campaign = a.getActiveCampaign
      if !campaign.nil?
        budget_total += campaign.getCampaignValue
      else
        a.campaigns.each do |c|
          if c.submitted == true && c.active == false && c.accepted == false
            budget_total += c.getCampaignValue
            break
          end
        end
      end
    end

    return budget_total
  end

  def updateDevReservedBalance
    temp_balance = 0.0
    temp_used_balance = 0.0
    self.apps.each do |a|
      campaign = a.getActiveCampaign
      if !campaign.nil?
        temp_campaign_histories = CampaignHistory.where(:campaign_id => campaign.id).where("created_at >= ?", 3.days.ago)
        temp_balance += (campaign.getCampaignValue * temp_campaign_histories.length)
        if !temp_campaign_histories.nil?
          temp_campaign_histories.each do |ch|
            ch.getAchievementHistories.each do |ah|
              temp_used_balance += ah.cost
            end
          end
        end
      end
    end

    developer_reserved_balance = temp_balance - temp_used_balance
    save

  end

end
