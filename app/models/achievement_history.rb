# The AchievementHistory class represents an instance of a user acquiring an achievements
class AchievementHistory < ActiveRecord::Base

                  # The date and time when the achievements was acquired
  attr_accessible :acquired,
                  # The number of "tokens" the user received for acquiring the achievements
                  :value,
                  # The amount in USD that the app owner pays/owes for this achievement completion
                  :cost

  # Relationships
  belongs_to :achievement
  belongs_to :device
end
