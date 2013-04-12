class Device < ActiveRecord::Base
  attr_accessible :description, :uuid

  #relationships
  belongs_to :user
  has_many :app_session_histories
end
