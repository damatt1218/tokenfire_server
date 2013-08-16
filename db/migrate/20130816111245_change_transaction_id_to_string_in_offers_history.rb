class ChangeTransactionIdToStringInOffersHistory < ActiveRecord::Migration
  def up
    change_column :offer_histories, :transaction_id, :string
  end

end
