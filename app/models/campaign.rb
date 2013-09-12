class Campaign < ActiveRecord::Base
  attr_accessible :name,
                  :description,
                  :overall_budget,
                  :overall_used_budget,
                  :daily_budget,
                  :daily_used_budget,
                  :duration,
                  :active,
                  :approved,
                  :app_id,
                  :soft_deleted

  belongs_to :app
  has_many :achievements
  has_many :campaign_histories
end
