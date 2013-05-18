# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


#  Role.create(name: 'Prospective Developer')

adminRole = Role.find_or_create_by_name!('Admin')

developerRole = Role.find_or_create_by_name!('Developer')

Role.find_or_create_by_name!('Member')
Role.find_or_create_by_name!('Prospective Developer')

user = User.find_or_create_by_username!(:username => 'tokenfire_admin', :password => 'tokenfire', :password_confirmation => 'tokenfire')
user.roles = [adminRole]

user2 = User.find_or_create_by_username!(:username => 'tokenfire_developer', :password => 'tokenfire', :password_confirmation => 'tokenfire')
user2.roles = [developerRole]

# add default app so we don't have to keep swapping out our app id in the sdk sandbox app
sandbox_app = user2.account.apps.find_or_create_by_name!( :name => 'tokenfiresandbox', :redirect_uri => 'urn:ietf:wg:oauth:2.0:oob',
                            :description => 'TokenFire sandbox application for testing', :image => '')

sandbox_app.uid = '6533f4c7beb3e2054984092401674aa2ea198d291c2e9e642c652209fe1cd829'
sandbox_app.secret = 'b6df5911a6548a762623812910673749e39dcfecddc9afad2e00557ac0de186a'
sandbox_app.save





