class Campaign < ActiveRecord::Base
  attr_accessible :name,
                  :description,
                  # The amount in USD that the app owner is willing to spend on this campaign
                  :overall_budget,
                  # The amount in USD that has been "reserved" for use.
                  :overall_used_budget,
                  # The real amount in USD that has been spent overall (counts actual achievement completions)
                  :actual_overall_spent,
                  # The amount in USD that the app owner is willing to spend per day.
                  :daily_budget,
                  # The amount in USD that has been "Reserved" for use on the current day.
                  :daily_used_budget,
                  # The real amount in USD that has been spent current day (counts actual achievement completions)
                  :actual_daily_spent,
                  # How long the campaign is good for once a user has downloaded the app
                  :duration,
                  :active,
                  :approved,
                  :app_id,
                  :soft_deleted,
                  :apk,
                  :submitted,
                  :accepted

  belongs_to :app
  has_many :achievements
  has_many :campaign_histories

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :overall_budget
  validates_presence_of :daily_budget
  validates :overall_budget, :format => { :with => /^\d+??(?:\.\d{0,2})?$/ }, :numericality => {:greater_than => 0}
  validates :daily_budget, :format => { :with => /^\d+??(?:\.\d{0,2})?$/ }, :numericality => {:greater_than => 0}
  validate :validate_budgets

  mount_uploader :apk, ApkUploader

  def validate_budgets
    if !daily_budget.nil? && !overall_budget.nil?
      if daily_budget > overall_budget
        errors.add :budget, " - The daily budget must be less than the overall budget."
      end
    end
  end

  # Checks to make see if the campaign is valid based on the active and approved boolean as well as
  # check to make sure there is enough daily and overall budgets left.  Mainly used to see if this app
  # should be displayed in the tokenfire mobile app
  def isAvailable
    if self.active? && self.approved?
      if (self.achievements.sum(&:cost) > (self.overall_budget - self.overall_used_budget)) ||
        (self.achievements.sum(&:cost) > (self.daily_budget - self.daily_used_budget))
        return false
      else
        return true
      end
    else
      return false
    end
  end

  # Gets the total cost if a user were to complete all achievements associated with a campaign
  def getCampaignValue
    return self.achievements.sum(&:cost)
  end

  # check to make sure there is enough remaining budget based on a passed in cost
  def hasRemainingBudget(cost)
    if (cost < (overall_budget - actual_overall_spent)) &&
       (cost < (daily_budget - actual_daily_spent))
      return true
    else
      return false
    end
  end

  def updateUsedBudgetValues(reserve_value, real_value)

    # add to the actual overall spent
    self.actual_overall_spent += real_value

    # if it is a new day, need to recalculate overall_used_budget and reset daily_used_budget and actual_daily_spent
    if Date.today > self.updated_at.to_date
      self.daily_used_budget = reserve_value
      self.actual_daily_spent = real_value

      temp_overall_used_budget = 0
      campaign_histories = CampaignHistory.where('created_at >= ?', 3.days.ago.beginning_of_day)
      campaign_histories.each do |c|
        temp_overall_used_budget += c.campaign.getCampaignValue
      end
      achievement_histories = AchievementHistory.where('created_at <= ?', 3.days.ago.beginning_of_day)
      achievement_histories.each do |a|
        temp_overall_used_budget += a.cost
      end
      self.overall_used_budget = temp_overall_used_budget

    else
      self.actual_daily_spent += real_value
      self.daily_used_budget += reserve_value
      self.overall_used_budget += reserve_value
    end

    save

  end
end
