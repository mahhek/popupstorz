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

ActiveRecord::Schema.define(:version => 20120504112158) do

  create_table "accounts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "stripe_card_token"
    t.integer  "user_id"
    t.string   "email"
    t.string   "plan_id"
  end

  create_table "availability_options", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "availability_options_items", :id => false, :force => true do |t|
    t.integer "availability_option_id"
    t.integer "item_id"
  end

  create_table "avatars", :force => true do |t|
    t.integer  "item_id"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50, :default => ""
    t.string   "comment",                        :default => ""
    t.datetime "created_at"
    t.integer  "commentable_id",                 :default => 0,  :null => false
    t.string   "commentable_type", :limit => 15, :default => "", :null => false
    t.integer  "user_id",                        :default => 0,  :null => false
    t.datetime "updated_at"
  end

  create_table "countries", :force => true do |t|
    t.string  "iso"
    t.string  "name"
    t.string  "printable_name"
    t.string  "iso3"
    t.integer "numcode"
  end

  create_table "items", :force => true do |t|
    t.string   "title"
    t.integer  "user_id"
    t.integer  "listing_type_id"
    t.text     "description"
    t.string   "address"
    t.float    "price"
    t.string   "price_unit"
    t.string   "time_for_unit_price"
    t.datetime "availability_from"
    t.datetime "availability_to"
    t.string   "time_period"
    t.string   "size"
    t.string   "size_unit"
    t.string   "type"
    t.boolean  "is_shareable",                                        :default => true
    t.integer  "maximum_members"
    t.boolean  "is_agree"
    t.string   "neighbourhood"
    t.string   "country_code"
    t.string   "county"
    t.string   "region"
    t.string   "city"
    t.string   "zipcode"
    t.string   "street"
    t.decimal  "latitude",            :precision => 15, :scale => 10
    t.decimal  "longitude",           :precision => 15, :scale => 10
    t.string   "street_name"
    t.string   "street_number"
    t.integer  "locatable_id"
    t.string   "locatable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "show_on_home",                                        :default => false
    t.float    "cleaning_fee"
    t.float    "deposit"
    t.boolean  "is_recommended",                                      :default => false
    t.float    "price_per_week"
    t.float    "price_per_month"
    t.string   "item_status"
  end

  create_table "items_users", :id => false, :force => true do |t|
    t.integer "item_id"
    t.integer "user_id"
  end

  create_table "listing_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.string   "topic"
    t.text     "body"
    t.integer  "received_messageable_id"
    t.string   "received_messageable_type"
    t.integer  "sent_messageable_id"
    t.string   "sent_messageable_type"
    t.boolean  "opened",                     :default => false
    t.boolean  "recipient_delete",           :default => false
    t.boolean  "sender_delete",              :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ancestry"
    t.boolean  "recipient_permanent_delete", :default => false
    t.boolean  "sender_permanent_delete",    :default => false
  end

  add_index "messages", ["ancestry"], :name => "index_messages_on_ancestry"
  add_index "messages", ["sent_messageable_id", "received_messageable_id"], :name => "acts_as_messageable_ids"

  create_table "notifications", :force => true do |t|
    t.integer  "user_id"
    t.string   "notification_type"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "offer_messages", :force => true do |t|
    t.integer  "offer_id"
    t.text     "message"
    t.integer  "user_id"
    t.string   "msg_posted_as"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "offers", :force => true do |t|
    t.datetime "rental_start_date"
    t.datetime "rental_end_date"
    t.string   "pickup_location"
    t.float    "willingness_to_pay"
    t.integer  "required_response_by_owner_before"
    t.string   "additional_message"
    t.string   "status"
    t.integer  "item_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "total_amount"
    t.boolean  "preferred_location",                :default => false
    t.string   "preferred_address"
    t.datetime "cancellation_date"
  end

  create_table "payments", :force => true do |t|
    t.integer  "seller_id"
    t.integer  "renter_id"
    t.float    "amount"
    t.float    "rentareto_fee"
    t.float    "seller_amount"
    t.string   "email"
    t.string   "stripe_customer_token"
    t.string   "stripe_card_token"
    t.string   "transaction_number"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "offer_id"
  end

  create_table "ratings", :force => true do |t|
    t.integer  "communication_rating",               :default => 0
    t.integer  "accuracy_rating",                    :default => 0
    t.integer  "location_rating",                    :default => 0
    t.integer  "seriousness_rating",                 :default => 0
    t.integer  "commodities_rating",                 :default => 0
    t.integer  "value_rating",                       :default => 0
    t.string   "rateable_type",        :limit => 50, :default => "", :null => false
    t.integer  "rateable_id",                        :default => 0,  :null => false
    t.integer  "user_id",                            :default => 0,  :null => false
    t.datetime "created_at",                                         :null => false
  end

  add_index "ratings", ["user_id"], :name => "fk_ratings_user"

  create_table "services", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "uname"
    t.string   "uemail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sms", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "",    :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "verify_email"
    t.string   "mobile_phone"
    t.boolean  "gender"
    t.date     "date_of_birth"
    t.string   "activity"
    t.string   "security_question"
    t.string   "security_answer"
    t.string   "address1"
    t.string   "address2"
    t.string   "zip_code"
    t.string   "city"
    t.string   "country"
    t.text     "description"
    t.boolean  "admin",                                 :default => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
