# The Achievement class represents an in-app achievements that a user is
# rewarded with Token Fire "tokens" for acquiring
class Achievement < ActiveRecord::Base

                  # Name of the achievements
  attr_accessible :name,
                  # Description of the achievements
                  :description,
                  # How many "tokens" a user gets for acquiring the achievements
                  :value,
                  # How much the app owner pays when the achievements is acquired by a user
                  :cost,
                  # True if the achievements is currently available
                  :enabled,
                  # True if a user can acquire the achievements multiple times
                  :repeatable,
                  # Specify special rules to allow only some user to acquire the achievements
                  :availability

  # Relationships
  belongs_to :achievement_history
  belongs_to :app
end
