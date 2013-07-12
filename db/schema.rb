# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130712072715) do

  create_table "accounts", :force => true do |t|
    t.float    "balance",    :default => 0.0
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "user_id"
  end

  add_index "accounts", ["user_id"], :name => "index_accounts_on_user_id"

  create_table "achievement_histories", :force => true do |t|
    t.datetime "acquired"
    t.integer  "value"
    t.integer  "device_id"
    t.integer  "achievement_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "achievements", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "value"
    t.decimal  "cost"
    t.boolean  "enabled"
    t.boolean  "repeatable"
    t.string   "availability"
    t.string   "uid"
    t.integer  "app_id"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.boolean  "soft_deleted", :default => false
  end

  create_table "app_daily_summaries", :force => true do |t|
    t.integer  "app_id"
    t.date     "summary_date"
    t.integer  "dau_count"
    t.integer  "session_count"
    t.integer  "device_count"
    t.integer  "total_duration"
    t.integer  "average_duration"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "app_session_histories", :force => true do |t|
    t.string   "session_id"
    t.string   "sdkVersion"
    t.datetime "eventTimeStamp"
    t.integer  "SessionDuration"
    t.integer  "device_id"
    t.integer  "app_usage_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "app_sessions", :force => true do |t|
    t.string   "reported_session_id"
    t.datetime "session_start"
    t.integer  "session_duration"
    t.string   "sdk_version"
    t.integer  "device_id"
    t.integer  "app_usage_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "app_usages", :force => true do |t|
    t.integer  "account_id"
    t.integer  "app_id"
    t.integer  "usage_time"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "app_usages", ["account_id", "app_id"], :name => "index_app_usages_on_account_id_and_app_id"

  create_table "apps", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "image"
    t.integer  "rating"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.string   "uid"
    t.string   "secret"
    t.string   "redirect_uri"
    t.integer  "account_id"
    t.integer  "featured_value", :default => 0
    t.string   "url"
    t.boolean  "disabled",       :default => false
    t.boolean  "accepted",       :default => false
  end

  add_index "apps", ["account_id"], :name => "index_apps_on_account_id"
  add_index "apps", ["uid"], :name => "index_apps_on_uid", :unique => true

  create_table "device_metrics_histories", :force => true do |t|
    t.string   "OS"
    t.string   "OS_version"
    t.string   "Device_Type"
    t.string   "Resolution"
    t.string   "Carrier"
    t.string   "AppVersion"
    t.string   "Location"
    t.string   "Locale"
    t.integer  "app_session_history_id"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  create_table "devices", :force => true do |t|
    t.string   "uuid"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "user_id"
  end

  add_index "devices", ["user_id"], :name => "index_devices_on_user_id"
  add_index "devices", ["uuid"], :name => "index_devices_on_uuid", :unique => true

  create_table "downloads", :force => true do |t|
    t.integer  "device_id"
    t.integer  "app_id"
    t.boolean  "pending"
    t.datetime "link_click_time"
    t.datetime "initial_launch_time"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "app_download_id"
  end

  create_table "gcm_devices", :force => true do |t|
    t.string   "registration_id",    :null => false
    t.datetime "last_registered_at"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "gcm_devices", ["registration_id"], :name => "index_gcm_devices_on_registration_id", :unique => true

  create_table "gcm_notifications", :force => true do |t|
    t.integer  "device_id",        :null => false
    t.string   "collapse_key"
    t.text     "data"
    t.boolean  "delay_while_idle"
    t.datetime "sent_at"
    t.integer  "time_to_live"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "gcm_notifications", ["device_id"], :name => "index_gcm_notifications_on_device_id"

  create_table "oauth_access_grants", :force => true do |t|
    t.integer  "resource_owner_id", :null => false
    t.integer  "application_id",    :null => false
    t.string   "token",             :null => false
    t.integer  "expires_in",        :null => false
    t.string   "redirect_uri",      :null => false
    t.datetime "created_at",        :null => false
    t.datetime "revoked_at"
    t.string   "scope"
  end

  add_index "oauth_access_grants", ["token"], :name => "index_oauth_access_grants_on_token", :unique => true

  create_table "oauth_access_tokens", :force => true do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id",    :null => false
    t.string   "token",             :null => false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        :null => false
    t.string   "scope"
  end

  add_index "oauth_access_tokens", ["refresh_token"], :name => "index_oauth_access_tokens_on_refresh_token", :unique => true
  add_index "oauth_access_tokens", ["resource_owner_id"], :name => "index_oauth_access_tokens_on_resource_owner_id"
  add_index "oauth_access_tokens", ["token"], :name => "index_oauth_access_tokens_on_token", :unique => true

  create_table "offer_histories", :force => true do |t|
    t.integer  "transaction_id"
    t.string   "company"
    t.integer  "amount"
    t.integer  "device_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "reward_histories", :force => true do |t|
    t.integer  "account_id"
    t.integer  "reward_id"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.boolean  "processed",       :default => false
    t.string   "redemption_code"
  end

  add_index "reward_histories", ["account_id", "reward_id"], :name => "index_reward_histories_on_account_id_and_reward_id"

  create_table "rewards", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "cost"
    t.string   "image"
    t.date     "expiration"
    t.integer  "quantity"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "featured_value", :default => 0
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "authentication_token"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "company"
    t.string   "username"
    t.boolean  "registered",             :default => false
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
