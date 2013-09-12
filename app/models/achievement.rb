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
                  :availability,
                  # Unique identifier for the achievement to be used in the RESTful API
                  :uid,
                  # True if the user has "deleted" the achievement.  Will be a soft delete
                  :soft_deleted

  # Relationships
  has_many :achievement_history
  belongs_to :app
  belongs_to :campaign

  validates_presence_of :name, :cost

  validates :cost, :format => { :with => /^\d+??(?:\.\d{0,2})?$/ }, :numericality => {:greater_than => 0, :less_than => 100}

  after_initialize :defaults

  def defaults
    unless persisted?
      self.uid ||= SecureRandom.urlsafe_base64(15)
    end
  end
end
