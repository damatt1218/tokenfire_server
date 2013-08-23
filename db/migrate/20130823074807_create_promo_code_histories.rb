class CreatePromoCodeHistories < ActiveRecord::Migration
  def change
    create_table :promo_code_histories do |t|
      t.references :promo_code
      t.references :account
      t.integer :value

      t.timestamps
    end
    add_index :promo_code_histories, :promo_code_id
    add_index :promo_code_histories, :account_id
  end
end
