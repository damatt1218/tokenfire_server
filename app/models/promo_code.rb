class PromoCode < ActiveRecord::Base
  attr_accessible :name, :value, :active, :as => :admin

  attr_accessible :active, :name, :value
end
