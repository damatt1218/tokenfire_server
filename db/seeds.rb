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

# Option to initialize db with a fake reward
if false
  reward = Reward.find_or_create_by_name!('Test Reward')
  reward.cost = 100
  reward.description = "This is where the reward description goes"
  reward.image = "http://placekitten.com/60/60"
  reward.save
end

# Optionally seed the database with fake session data to drive reports
if false

  num_users = 50
  max_devices_per_user = 2
  days_of_data = 100
  max_sessions_per_device = 40

  user_counter = 0

  until user_counter > num_users do
    puts('creating user ' + user_counter.to_s + ' of ' + num_users.to_s)

    current_user = User.find_or_create_by_android_id(SecureRandom.uuid)

    user_devices = rand(max_devices_per_user)
    device_counter = 0

    until device_counter > user_devices do

      puts('creating device ' + device_counter.to_s + ' of ' + user_devices.to_s)

      new_device_id =  SecureRandom.uuid
      current_device = Device.find_or_create_by_uuid(new_device_id)
      current_device.user = current_user
      current_device.save
      puts('saved device ' + current_device.uuid.to_s)

      session_count = rand(max_sessions_per_device)

      session_counter = 0

      until session_counter > session_count do

        session_start_date = DateTime.current - rand(days_of_data).day
        session_minutes = rand(120) # max 8 hours per session

        puts('creating session ' + session_counter.to_s + ' of ' + session_count.to_s + ' with a start date of ' + session_start_date.to_s + ' and a max session minutes of ' + session_minutes.to_s)


        session_id = SecureRandom.uuid
        app_session = current_device.app_sessions.where(:reported_session_id => session_id).first_or_create()
        app_session.sdk_version = '0.1'
        app_session.session_start = session_start_date
        app_session.app_usage = AppUsage.find_or_create_by_app_id_and_user_id(sandbox_app.id, current_user.id)

        session_minutes = rand(480) # max 8 hours per session

        session_minute_counter = 0

        until session_minute_counter >  session_minutes do

          current_session_time = session_start_date + session_minute_counter.minute
          app_session.session_duration =  session_minute_counter

          app_session_history = app_session.app_session_histories.new
          app_session_history.event_timestamp= current_session_time
          app_session_history.reported_duration = session_minute_counter


          app_session.save




          session_minute_counter += 15
        end

        AppDailySummary.update_for_date(sandbox_app, session_start_date.to_date)

        session_counter += 1
      end
      sandbox_app.app_usages.each { |app_usage| app_usage.update_usage_from_sessions }



      device_counter += 1
    end


    user_counter += 1
  end



end





