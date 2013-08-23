class AddReferralCodeToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :referral_code, :string
  end
end
