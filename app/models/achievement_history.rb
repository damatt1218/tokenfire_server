# The AchievementHistory class represents an instance of a user acquiring an achievements
class AchievementHistory < ActiveRecord::Base

                  # The date and time when the achievements was acquired
  attr_accessible :acquired,
                  # The number of "tokens" the user received for acquiring the achievements
                  :value

  # Relationships
  has_one :app
  belongs_to :device
end
