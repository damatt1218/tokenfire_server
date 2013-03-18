class AddUsernameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :username, :string

    user = User.create!(:username => 'tokenfire_admin', :password => 'tokenfire', :password_confirmation => 'tokenfire')
    user.add_role_id(1)
  end
end
