class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :name
      t.string :description
      t.boolean :active
      t.boolean :approved
      t.float :overall_budget
      t.float :daily_budget
      t.float :duration
      t.integer :app_id

      t.timestamps
    end
  end
end
