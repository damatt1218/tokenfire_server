class Reward < ActiveRecord::Base
  attr_accessible :name, :description, :cost, :quantity, :expiration, :image, :remote_image_url, :featured_value, :as => :admin

  # Scopes
  # Featured rewards ordered least to greatest
  scope :featured, where("featured_value > ?", 0).order("featured_value ASC")

  # Relationships
  has_many :reward_histories
  has_many :accounts, :through => :reward_histories

  mount_uploader :image, ImageUploader

  validate :validate_image_size

  def validate_image_size
    if !image.nil? && !image.path.nil? && !image.to_s.include?("AKIAIWYJD4O3PQX4ETIA")
      open_image = MiniMagick::Image.open(image.path)
       unless open_image[:width] == 96 && open_image[:height] == 96
         errors.add :image, "should be 96x96px!"
       end
    end
  end
end
