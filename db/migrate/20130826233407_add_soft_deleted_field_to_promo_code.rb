class AddSoftDeletedFieldToPromoCode < ActiveRecord::Migration
  def change
    add_column :promo_codes, :soft_deleted, :boolean, :default => false
  end
end
