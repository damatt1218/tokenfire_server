class CreateAchievements < ActiveRecord::Migration
  def change
    create_table :achievements do |t|
      t.string :name
      t.string :description
      t.integer :value
      t.decimal :cost
      t.boolean :enabled
      t.boolean :repeatable
      t.string :availability
      t.integer :app_id

      t.timestamps
    end
  end
end
