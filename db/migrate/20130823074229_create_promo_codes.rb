class CreatePromoCodes < ActiveRecord::Migration
  def change
    create_table :promo_codes do |t|
      t.string :name
      t.integer :value
      t.boolean :active

      t.timestamps
    end
  end
end
