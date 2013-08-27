class AddDescriptionToPromoCodes < ActiveRecord::Migration
  def change
    add_column :promo_codes, :description, :text
  end
end
