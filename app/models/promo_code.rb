class PromoCode < ActiveRecord::Base
  attr_accessible :name, :value, :active, :description,   :as => :admin
end
