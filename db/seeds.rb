# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


#  Role.create(name: 'Prospective Developer')

adminRole = Role.create!(:name => 'Admin')
Role.create!(:name => 'Developer')
Role.create!(:name => 'Member')
Role.create!(:name => 'Prospective Developer')

user = User.create!(:username => 'tokenfire_admin', :password => 'tokenfire', :password_confirmation => 'tokenfire')
user.roles = [adminRole]



