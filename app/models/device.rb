class Device < ActiveRecord::Base
  attr_accessible :description, :uuid

  #relationships
  belongs_to :user
  has_many :achievement_histories
  has_many :app_session_histories
end
