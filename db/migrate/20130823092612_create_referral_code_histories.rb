class CreateReferralCodeHistories < ActiveRecord::Migration
  def change
    create_table :referral_code_histories do |t|
      t.references :account
      t.integer :referrer_id
      t.integer :referree_value
      t.integer :referrer_value

      t.timestamps
    end
    add_index :referral_code_histories, :account_id
  end
end
