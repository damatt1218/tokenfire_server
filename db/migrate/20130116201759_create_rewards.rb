class CreateRewards < ActiveRecord::Migration
  def change
    create_table :rewards do |t|
      t.string :name
      t.text :description
      t.integer :cost
      t.string :image
      t.date :expiration
      t.integer :quantity

      t.timestamps
    end
  end
end
