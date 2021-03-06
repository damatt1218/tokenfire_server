class CreateDoorkeeperTables < ActiveRecord::Migration
  def change
    create_table :oauth_access_grants do |t|
      t.integer  :resource_owner_id, :null => false
      t.integer  :application_id,    :null => false
      t.string   :token,             :null => false
      t.integer  :expires_in,        :null => false
      t.string   :redirect_uri,      :null => false
      t.datetime :created_at,        :null => false
      t.datetime :revoked_at
      t.string   :scope
    end

    add_index :oauth_access_grants, :token, :unique => true

    create_table :oauth_access_tokens do |t|
      t.integer  :resource_owner_id
      t.integer  :application_id,    :null => false
      t.string   :token,             :null => false
      t.string   :refresh_token
      t.integer  :expires_in
      t.datetime :revoked_at
      t.datetime :created_at,        :null => false
      t.string   :scope
    end

    add_index :oauth_access_tokens, :token, :unique => true
    add_index :oauth_access_tokens, :resource_owner_id
    add_index :oauth_access_tokens, :refresh_token, :unique => true
  end
end
