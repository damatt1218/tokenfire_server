class Device < ActiveRecord::Base
  attr_accessible :description, :uuid

  #relationships
  belongs_to :user
end
