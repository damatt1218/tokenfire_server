class CreateOfferHistories < ActiveRecord::Migration
  def change
    create_table :offer_histories do |t|
      t.integer :transaction_id
      t.string :company
      t.integer :amount
      t.integer :device_id

      t.timestamps
    end
  end
end
