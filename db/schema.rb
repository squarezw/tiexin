# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110103113411) do

  create_table "access_logs", :force => true do |t|
    t.integer  "member_id"
    t.datetime "created_at"
    t.boolean  "mobile"
    t.string   "locale",          :limit => 5
    t.string   "remote_ip",       :limit => 15
    t.string   "controller",      :limit => 256
    t.string   "action",          :limit => 256
    t.string   "method",          :limit => 10
    t.string   "user_agent",      :limit => 1024
    t.string   "referer",         :limit => 4096
    t.string   "request_uri",     :limit => 4096
    t.string   "response_status", :limit => 20
    t.string   "browser",         :limit => 50
    t.string   "browser_version", :limit => 50
    t.boolean  "from_robot"
  end

  add_index "access_logs", ["created_at"], :name => "index_access_logs_on_created_at"

  create_table "areas", :force => true do |t|
    t.integer "city_id",                                                                  :null => false
    t.string  "name_en",     :limit => 60
    t.string  "name_zh_cn",  :limit => 60
    t.integer "nw_x"
    t.integer "nw_y"
    t.integer "width"
    t.integer "height"
    t.integer "center_x"
    t.integer "center_y"
    t.integer "visit_count",                                               :default => 0
    t.decimal "latitude",                  :precision => 18, :scale => 15
    t.decimal "longitude",                 :precision => 18, :scale => 15
  end

  create_table "articles", :force => true do |t|
    t.string   "subject",        :limit => 3000, :default => "",    :null => false
    t.integer  "member_id",                                         :null => false
    t.integer  "folder_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "read_times",                     :default => 0,     :null => false
    t.integer  "comments_count",                 :default => 0
    t.integer  "brand_id"
    t.text     "content"
    t.string   "summary",        :limit => 1000
    t.integer  "rss_source_id"
    t.string   "link",           :limit => 500
    t.datetime "synch_date"
    t.integer  "post_id"
    t.integer  "check_status",                   :default => 0
    t.boolean  "recommended",                    :default => false
  end

  create_table "articles_hot_spots", :id => false, :force => true do |t|
    t.integer "article_id",  :null => false
    t.integer "hot_spot_id", :null => false
  end

  create_table "articles_topics", :id => false, :force => true do |t|
    t.integer  "article_id", :null => false
    t.integer  "topic_id",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bbs_blacklists", :id => false, :force => true do |t|
    t.integer  "forum_id",   :null => false
    t.integer  "member_id",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blog_access_logs", :force => true do |t|
    t.integer  "member_id"
    t.integer  "blog_id",    :null => false
    t.datetime "created_at"
  end

  create_table "blogs", :force => true do |t|
    t.string   "name",        :limit => 30, :default => "", :null => false
    t.string   "simple_name", :limit => 30, :default => "", :null => false
    t.string   "picture",     :limit => 50
    t.integer  "skin_id",                   :default => 1,  :null => false
    t.integer  "owner_id",                                  :null => false
    t.integer  "read_times",                :default => 0,  :null => false
    t.datetime "read_time"
    t.string   "read_ip",     :limit => 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "brands", :force => true do |t|
    t.string   "name_zh_cn",           :limit => 300
    t.string   "name_en",              :limit => 300
    t.string   "pic"
    t.string   "intro",                :limit => 3000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.string   "home_page",            :limit => 1000
    t.integer  "visit_count",                          :default => 0
    t.integer  "owner_id"
    t.integer  "hot_spot_category_id"
  end

  create_table "bulletins", :force => true do |t|
    t.string   "title",       :limit => 90, :default => "",      :null => false
    t.string   "language",    :limit => 10, :default => "zh_cn", :null => false
    t.text     "content"
    t.date     "expire_date"
    t.datetime "created_at"
  end

  create_table "campaigns", :force => true do |t|
    t.string   "name",             :limit => 300,  :default => "", :null => false
    t.integer  "trigger",                          :default => 1,  :null => false
    t.integer  "bonus_experience",                 :default => 0
    t.integer  "bonus_credit",                     :default => 0
    t.date     "expire_date",                                      :null => false
    t.string   "confirm_message",  :limit => 1000, :default => "", :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "channel_daily_contents", :force => true do |t|
    t.integer  "channel_id",                                :null => false
    t.string   "title",      :limit => 300, :default => "", :null => false
    t.date     "display_at",                                :null => false
    t.string   "picture",    :limit => 300
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "channels", :force => true do |t|
    t.integer "hot_spot_category_id",                                   :null => false
    t.integer "forum_id",                                               :null => false
    t.string  "icon",                 :limit => 100
    t.string  "name_zh_cn",                          :default => "",    :null => false
    t.string  "name_en",                             :default => "",    :null => false
    t.boolean "has_daily_content",                   :default => false
    t.string  "daily_content_title",  :limit => 30
  end

  create_table "cities", :force => true do |t|
    t.string   "name_en",       :limit => 180
    t.string   "name_zh_cn",    :limit => 180
    t.integer  "width"
    t.integer  "height"
    t.decimal  "x0",                            :precision => 12, :scale => 2
    t.decimal  "y0",                            :precision => 12, :scale => 2
    t.integer  "start_point_x"
    t.integer  "start_point_y"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo",         :limit => 100
    t.string   "weather_code",  :limit => 2048
    t.boolean  "has_map",                                                       :default => true
    t.decimal  "latitude",                      :precision => 18, :scale => 15
    t.decimal  "longitude",                     :precision => 18, :scale => 15
  end

  create_table "cities_coupons", :id => false, :force => true do |t|
    t.integer "city_id",   :null => false
    t.integer "coupon_id", :null => false
  end

  create_table "cities_events", :id => false, :force => true do |t|
    t.integer "city_id",  :null => false
    t.integer "event_id", :null => false
  end

  create_table "comments", :force => true do |t|
    t.string   "commentable_type", :default => "", :null => false
    t.integer  "commentable_id",                   :null => false
    t.integer  "member_id",                        :null => false
    t.datetime "created_at",                       :null => false
    t.text     "content"
    t.integer  "status",           :default => 1
    t.integer  "agree",            :default => 0
    t.integer  "disagree",         :default => 0
  end

  create_table "contents", :force => true do |t|
    t.integer "post_id", :null => false
    t.text    "content"
  end

  create_table "coupon_templates", :force => true do |t|
    t.string "content", :limit => 90, :default => "", :null => false
  end

  create_table "coupons", :force => true do |t|
    t.string   "vendor_type", :limit => 100,  :default => "",    :null => false
    t.integer  "vendor_id",                                      :null => false
    t.integer  "member_id",                                      :null => false
    t.integer  "admin_id"
    t.string   "type",        :limit => 100,  :default => "",    :null => false
    t.integer  "event_id"
    t.date     "expire_at",                                      :null => false
    t.boolean  "all_city",                    :default => false
    t.integer  "status",                      :default => 1
    t.boolean  "available",                   :default => true
    t.string   "summary",     :limit => 3000, :default => "",    :null => false
    t.text     "terms"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "daq_events", :force => true do |t|
    t.string   "event_name"
    t.string   "event_content",     :limit => 20000
    t.string   "hot_spot_name"
    t.string   "hot_spot_address"
    t.string   "picture"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "event_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published"
  end

  create_table "districts", :force => true do |t|
    t.integer  "city_id"
    t.string   "name_en",    :limit => 180
    t.string   "name_zh_cn", :limit => 180
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "download_logs", :force => true do |t|
    t.string   "platform",   :limit => 50, :default => "", :null => false
    t.string   "version",    :limit => 10, :default => "", :null => false
    t.datetime "created_at",                               :null => false
  end

  create_table "error_logs", :force => true do |t|
    t.integer  "member_id"
    t.text     "request_uri"
    t.text     "http_headers"
    t.text     "parameters"
    t.text     "error_messages"
    t.text     "stack_trace"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_categories", :force => true do |t|
    t.string   "name_zh_cn", :limit => 60
    t.string   "name_en",    :limit => 60
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.string   "vendor_type",       :limit => 20
    t.integer  "vendor_id"
    t.integer  "member_id"
    t.string   "summary_en",        :limit => 3000, :default => "",    :null => false
    t.string   "summary_zh_cn",     :limit => 3000, :default => "",    :null => false
    t.text     "content_en"
    t.text     "content_zh_cn"
    t.date     "begin_date"
    t.date     "end_date"
    t.string   "banner",            :limit => 500
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "allcity",                           :default => false
    t.string   "post",              :limit => 500
    t.string   "type",              :limit => 20
    t.string   "global_id"
    t.string   "reference_url",     :limit => 2048
    t.integer  "event_category_id"
  end

  create_table "events_tags", :id => false, :force => true do |t|
    t.integer "event_id", :null => false
    t.integer "tag_id",   :null => false
  end

  create_table "folders", :force => true do |t|
    t.string  "name",      :limit => 90, :default => "", :null => false
    t.integer "member_id",                               :null => false
  end

  create_table "forums", :force => true do |t|
    t.integer "order_sequence",                 :null => false
    t.string  "name",           :limit => 150
    t.string  "description",    :limit => 3000
  end

  create_table "forums_members", :id => false, :force => true do |t|
    t.integer  "forum_id",   :null => false
    t.integer  "member_id",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friend_links", :force => true do |t|
    t.string   "title"
    t.string   "link"
    t.integer  "channel_id"
    t.string   "vendor_type"
    t.integer  "visit_count"
    t.string   "js"
    t.string   "pic"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friends", :force => true do |t|
    t.integer  "owner_id",                     :null => false
    t.integer  "member_id",                    :null => false
    t.boolean  "pending",    :default => true
    t.datetime "created_at"
  end

  create_table "gift_order_items", :force => true do |t|
    t.integer  "gift_order_id",                :null => false
    t.integer  "gift_id",                      :null => false
    t.integer  "quantity",      :default => 1, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gift_orders", :force => true do |t|
    t.integer  "member_id",                                        :null => false
    t.integer  "deliver_method",                                   :null => false
    t.integer  "payment_method",                                   :null => false
    t.string   "city",             :limit => 300
    t.string   "address",          :limit => 900
    t.string   "post_code",        :limit => 10
    t.string   "phone_number",     :limit => 15
    t.string   "phone_number2",    :limit => 15
    t.string   "name",             :limit => 300
    t.integer  "used_experience",                 :default => 0,   :null => false
    t.integer  "used_credit",                     :default => 0,   :null => false
    t.float    "cash",                            :default => 0.0, :null => false
    t.integer  "status",                          :default => 0,   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "certificate_type", :limit => 90
    t.string   "certificate_no",   :limit => 30
    t.datetime "confirmed_at"
    t.integer  "partner_id"
    t.date     "plan_fetch_date"
    t.string   "recommender",      :limit => 100
    t.datetime "delivered_at"
  end

  create_table "gifts", :force => true do |t|
    t.string   "name",                   :limit => 300, :default => "",   :null => false
    t.integer  "experience",                            :default => 0,    :null => false
    t.integer  "credit",                                :default => 0,    :null => false
    t.integer  "cash",                                  :default => 0,    :null => false
    t.integer  "total_quantity",                        :default => -1,   :null => false
    t.integer  "sold_quantity",                         :default => 0,    :null => false
    t.integer  "booked_quantity",                       :default => 0,    :null => false
    t.integer  "delivery_fee",                          :default => 0,    :null => false
    t.boolean  "on_sale",                               :default => true, :null => false
    t.string   "picture",                :limit => 100
    t.text     "description",                                             :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "reference_price"
    t.string   "reference_url",          :limit => 300
    t.string   "support_deliver_method"
    t.integer  "partner_id"
  end

  create_table "hot_spot_access_logs", :force => true do |t|
    t.integer  "member_id"
    t.integer  "hot_spot_id", :null => false
    t.datetime "created_at"
    t.boolean  "from_mobile"
  end

  create_table "hot_spot_categories", :force => true do |t|
    t.string   "name_en",           :limit => 60
    t.string   "name_zh_cn",        :limit => 60
    t.integer  "parent_id"
    t.string   "icon"
    t.string   "icon_mime_type"
    t.string   "icon_filesize"
    t.integer  "traffic_stop_type",                :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "map_icon"
    t.string   "big_icon"
    t.integer  "order_weight",                     :default => 0
    t.string   "keyword",           :limit => 300
    t.boolean  "common",                           :default => false
  end

  create_table "hot_spot_scores", :force => true do |t|
    t.integer  "hot_spot_id",                :null => false
    t.integer  "member_id",                  :null => false
    t.integer  "quality",     :default => 0
    t.integer  "service",     :default => 0
    t.integer  "environment", :default => 0
    t.integer  "price",       :default => 0
    t.datetime "created_at"
  end

  create_table "hot_spot_tags", :force => true do |t|
    t.string   "tag"
    t.string   "description", :limit => 3000
    t.integer  "member_id"
    t.integer  "hot_spot_id",                 :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "hot_spot_tags", ["tag"], :name => "index_hot_spot_tags_on_tag"

  create_table "hot_spots", :force => true do |t|
    t.integer  "city_id",                                                                                 :null => false
    t.integer  "hot_spot_category_id"
    t.string   "name_en",              :limit => 180
    t.string   "name_zh_cn",           :limit => 180
    t.string   "address_en",           :limit => 180
    t.string   "address_zh_cn",        :limit => 180
    t.integer  "x"
    t.integer  "y"
    t.string   "phone_number",         :limit => 60
    t.string   "introduction_en",      :limit => 3000
    t.string   "introduction_zh_cn",   :limit => 3000
    t.integer  "creator_id",                                                                              :null => false
    t.boolean  "approved"
    t.datetime "created_at"
    t.integer  "comments_count",                                                       :default => 0
    t.integer  "price_level"
    t.string   "price_memo",           :limit => 600
    t.integer  "parking_slot"
    t.integer  "container_id"
    t.string   "operation_time_zh_cn", :limit => 600
    t.string   "operation_time_en",    :limit => 600
    t.string   "home_page",            :limit => 450
    t.integer  "visit_count",                                                          :default => 0
    t.integer  "brand_id"
    t.integer  "owner_id"
    t.float    "quality_score",                                                        :default => 0.0
    t.float    "service_score",                                                        :default => 0.0
    t.float    "environment_score",                                                    :default => 0.0
    t.float    "price_score",                                                          :default => 0.0
    t.float    "score",                                                                :default => 0.0
    t.datetime "updated_at"
    t.integer  "score_count",                                                          :default => 0
    t.boolean  "recommend",                                                            :default => false
    t.datetime "recommend_expire_at"
    t.boolean  "ontop"
    t.decimal  "latitude",                             :precision => 18, :scale => 15
    t.decimal  "longitude",                            :precision => 18, :scale => 15
  end

  add_index "hot_spots", ["created_at"], :name => "index_hot_spots_on_created_at"

  create_table "hot_spots_members", :id => false, :force => true do |t|
    t.integer "hot_spot_id", :null => false
    t.integer "member_id",   :null => false
  end

  create_table "hot_spots_topics", :id => false, :force => true do |t|
    t.integer  "hot_spot_id", :null => false
    t.integer  "topic_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hot_topics", :force => true do |t|
    t.string   "title"
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hotel_reservation_details", :force => true do |t|
    t.integer  "hotel_reservation_id", :null => false
    t.integer  "hotel_room_id",        :null => false
    t.integer  "number"
    t.float    "price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hotel_reservations", :force => true do |t|
    t.integer  "hotel_id",                      :null => false
    t.integer  "member_id"
    t.date     "start_date"
    t.integer  "days"
    t.string   "contact",       :limit => 100
    t.string   "phone_number",  :limit => 100
    t.string   "memo",          :limit => 3000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tenant",        :limit => 100
    t.string   "mobile_number", :limit => 20
    t.date     "end_date"
  end

  create_table "hotel_rooms", :force => true do |t|
    t.integer  "hotel_id",                                       :null => false
    t.string   "name",           :limit => 1000, :default => "", :null => false
    t.float    "price",                                          :null => false
    t.string   "bed",            :limit => 1000
    t.boolean  "breakfast"
    t.boolean  "network"
    t.string   "pic"
    t.string   "memo",           :limit => 3000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "discount_price"
  end

  create_table "hotels", :force => true do |t|
    t.integer  "hot_spot_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo"
    t.string   "name"
    t.integer  "category_id"
    t.string   "address",     :limit => 500
    t.string   "map_1"
    t.string   "map_2"
    t.string   "map_3"
    t.integer  "city_id"
    t.integer  "district_id"
  end

  create_table "invitations", :force => true do |t|
    t.integer  "member_id",                     :null => false
    t.string   "mail",        :default => "",   :null => false
    t.boolean  "add_friends", :default => true
    t.datetime "created_at"
  end

  create_table "ip_sources", :force => true do |t|
    t.integer "ip_begin", :limit => 11, :precision => 11, :scale => 0, :null => false
    t.integer "ip_end",   :limit => 11, :precision => 11, :scale => 0, :null => false
    t.integer "city_id"
    t.string  "source"
  end

  add_index "ip_sources", ["ip_begin", "ip_end"], :name => "index_ip_sources_on_ip_begin_and_ip_end"

  create_table "layout_maps", :force => true do |t|
    t.string  "name_en",            :limit => 60
    t.string  "name_zh_cn",         :limit => 60
    t.string  "layoutable_type",                    :default => "", :null => false
    t.integer "layoutable_id",                                      :null => false
    t.string  "introduction_zh_cn", :limit => 3000
    t.string  "introduction_en",    :limit => 3000
  end

  create_table "map_levels", :force => true do |t|
    t.integer "city_id", :null => false
    t.integer "no",      :null => false
    t.float   "scale",   :null => false
    t.integer "row",     :null => false
    t.integer "column",  :null => false
  end

  create_table "member_privileges", :force => true do |t|
    t.integer "member_id", :null => false
    t.string  "privilege"
  end

  create_table "members", :force => true do |t|
    t.string   "login_name",                           :default => "",    :null => false
    t.string   "password_hash",                        :default => "",    :null => false
    t.string   "mail",                 :limit => 200,  :default => ""
    t.string   "nick_name"
    t.datetime "created_at",                                              :null => false
    t.boolean  "is_admin",                             :default => false, :null => false
    t.boolean  "confirmed",                            :default => false
    t.string   "confirm_code",         :limit => 100
    t.string   "favorite_lang",        :limit => 5
    t.string   "logo"
    t.string   "logo_mime_type",       :limit => 50
    t.string   "mobile_phone",         :limit => 20
    t.integer  "city_for_mobile"
    t.datetime "locked_until"
    t.integer  "experience",                           :default => 0
    t.integer  "credit",                               :default => 0
    t.boolean  "is_merchant",                          :default => false
    t.integer  "inviter_id"
    t.integer  "invitation_id"
    t.integer  "favorite_open_option",                 :default => 1
    t.boolean  "is_staff",                             :default => false
    t.integer  "used_experience",                      :default => 0
    t.integer  "used_credit",                          :default => 0
    t.string   "city",                 :limit => 200
    t.string   "address",              :limit => 900
    t.string   "post_code",            :limit => 10
    t.string   "phone_number2",        :limit => 15
    t.string   "real_name",            :limit => 300
    t.string   "certificate_type",     :limit => 90
    t.string   "certificate_no",       :limit => 30
    t.boolean  "mobile_register",                      :default => false
    t.string   "machine_code",         :limit => 100
    t.string   "mail_confirm_code"
    t.string   "mail_confirm"
    t.string   "sign",                 :limit => 3000
  end

  create_table "members_recommended_hot_spots", :id => false, :force => true do |t|
    t.integer "member_id",               :null => false
    t.integer "recommended_hot_spot_id", :null => false
  end

  create_table "messages", :force => true do |t|
    t.integer  "from_id",                                             :null => false
    t.integer  "to_id",                                               :null => false
    t.string   "title",            :limit => 300,  :default => "",    :null => false
    t.string   "content",          :limit => 3000
    t.boolean  "readed",                           :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "sender_deleted",                   :default => false
    t.boolean  "receiver_deleted",                 :default => false
  end

  create_table "mobile_brands", :force => true do |t|
    t.string   "name",       :default => "", :null => false
    t.string   "logo"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mobile_models", :force => true do |t|
    t.string   "name",                            :default => "", :null => false
    t.string   "picture"
    t.integer  "mobile_brand_id"
    t.integer  "mobile_os_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "summary",         :limit => 3000
  end

  create_table "mobile_os", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "navi_photos", :force => true do |t|
    t.string   "owner_type",                 :default => "", :null => false
    t.integer  "owner_id",                                   :null => false
    t.string   "subject",     :limit => 300
    t.string   "photo"
    t.integer  "uploader_id",                                :null => false
    t.datetime "created_at"
  end

  create_table "navi_stars", :force => true do |t|
    t.integer  "release",         :null => false
    t.integer  "major",           :null => false
    t.integer  "minor",           :null => false
    t.string   "suffix"
    t.string   "filename"
    t.integer  "mobile_os_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "minimum_release", :null => false
    t.integer  "minimum_major",   :null => false
    t.integer  "minimum_minor",   :null => false
    t.datetime "release_at"
  end

  create_table "operation_logs", :force => true do |t|
    t.integer  "member_id",                                           :null => false
    t.datetime "created_at",                                          :null => false
    t.string   "operation",           :limit => 50,   :default => "", :null => false
    t.string   "related_object_type", :limit => 50
    t.integer  "related_object_id"
    t.string   "message_key",         :limit => 2048
    t.string   "memo",                :limit => 3000
    t.text     "message_parameters"
  end

  create_table "owner_applications", :force => true do |t|
    t.string   "target_type", :limit => 30,  :default => "", :null => false
    t.integer  "target_id",                                  :null => false
    t.integer  "member_id",                                  :null => false
    t.integer  "status",                     :default => 0,  :null => false
    t.integer  "admin_id"
    t.datetime "created_at"
    t.string   "opinion",     :limit => 300
  end

  create_table "partners", :force => true do |t|
    t.string   "code",           :limit => 8,   :default => "", :null => false
    t.string   "name",           :limit => 300, :default => "", :null => false
    t.string   "phone_number",   :limit => 20,  :default => "", :null => false
    t.string   "contact_person", :limit => 60
    t.string   "mail",           :limit => 50
    t.string   "password_hash",                 :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pictures", :force => true do |t|
    t.string   "name",        :limit => 30,   :default => "", :null => false
    t.string   "photo"
    t.string   "tag_list",    :limit => 100
    t.string   "description", :limit => 1000
    t.integer  "read_times",                  :default => 0,  :null => false
    t.integer  "member_id",                                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "positions", :force => true do |t|
    t.integer "hot_spot_id",   :null => false
    t.integer "layout_map_id", :null => false
    t.float   "x",             :null => false
    t.float   "y",             :null => false
  end

  create_table "posts", :force => true do |t|
    t.string   "title",            :limit => 300, :default => "",    :null => false
    t.integer  "member_id",                                          :null => false
    t.integer  "forum_id",                                           :null => false
    t.datetime "created_at"
    t.datetime "last_replied_at"
    t.integer  "read_times",                      :default => 0,     :null => false
    t.integer  "vote_result",                     :default => 0,     :null => false
    t.integer  "replies_count",                   :default => 0,     :null => false
    t.boolean  "always_on_top",                   :default => false, :null => false
    t.boolean  "lock",                            :default => false, :null => false
    t.integer  "check_status",                    :default => 0,     :null => false
    t.integer  "good_score",                      :default => 0,     :null => false
    t.integer  "hidden_score",                    :default => 0,     :null => false
    t.integer  "water_score",                     :default => 0,     :null => false
    t.string   "attachment"
    t.datetime "updated_at"
    t.boolean  "deleted",                         :default => false
    t.boolean  "original"
    t.boolean  "show_in_homepage",                :default => false
  end

  create_table "posts_tags", :id => false, :force => true do |t|
    t.integer "post_id", :null => false
    t.integer "tag_id",  :null => false
  end

  create_table "posts_topics", :id => false, :force => true do |t|
    t.integer  "post_id",    :null => false
    t.integer  "topic_id",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", :force => true do |t|
    t.integer  "vendor_id",                                             :null => false
    t.string   "name_en",            :limit => 300
    t.string   "name_zh_cn",         :limit => 300
    t.boolean  "official",                           :default => false, :null => false
    t.string   "introduction_en",    :limit => 3000
    t.string   "introduction_zh_cn", :limit => 3000
    t.string   "photo"
    t.integer  "creator_id"
    t.integer  "last_updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "vendor_type",        :limit => 20
    t.string   "price",              :limit => 100
  end

  create_table "received_coupons", :force => true do |t|
    t.integer  "member_id",                                  :null => false
    t.integer  "coupon_id",                                  :null => false
    t.string   "name",         :limit => 30, :default => "", :null => false
    t.string   "phone_number", :limit => 15, :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recommended_hot_spots", :force => true do |t|
    t.integer  "member_id",                              :null => false
    t.integer  "hot_spot_id",                            :null => false
    t.boolean  "readed",              :default => false, :null => false
    t.datetime "created_at"
    t.datetime "last_recommended_at"
  end

  create_table "recommended_tags", :force => true do |t|
    t.string   "tag",        :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "replies", :force => true do |t|
    t.integer  "member_id",                          :null => false
    t.integer  "post_id",                            :null => false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "last_replied_at"
    t.integer  "vote_result",     :default => 0,     :null => false
    t.integer  "check_status"
    t.integer  "good_score",      :default => 0,     :null => false
    t.integer  "hidden_score",    :default => 0,     :null => false
    t.integer  "water_score",     :default => 0,     :null => false
    t.string   "attachment"
    t.text     "content"
    t.datetime "updated_at"
    t.boolean  "deleted",         :default => false, :null => false
  end

  create_table "revises", :force => true do |t|
    t.integer  "hot_spot_id",                                 :null => false
    t.integer  "member_id",                                   :null => false
    t.string   "suggestion",   :limit => 2048
    t.string   "remark",       :limit => 2048
    t.integer  "admin_id"
    t.datetime "processed_at"
    t.datetime "created_at"
    t.integer  "status",                       :default => 0, :null => false
  end

  create_table "road_segments", :force => true do |t|
    t.integer "road_id", :null => false
    t.integer "start_x", :null => false
    t.integer "start_y", :null => false
    t.integer "end_x",   :null => false
    t.integer "end_y",   :null => false
  end

  create_table "roads", :force => true do |t|
    t.integer "city_id",                   :null => false
    t.string  "name_zh_cn", :limit => 300
    t.string  "name_en",    :limit => 300
  end

  create_table "rss_sources", :force => true do |t|
    t.integer "blog_id"
    t.string  "rss",         :limit => 500,  :default => "", :null => false
    t.string  "title",       :limit => 2000
    t.text    "description"
    t.string  "link",        :limit => 500
    t.string  "language",    :limit => 20
    t.string  "icon_url",    :limit => 500
    t.string  "icon_title",  :limit => 2000
    t.string  "icon_link",   :limit => 500
    t.integer "score"
    t.integer "folder_id"
  end

  create_table "search_logs", :force => true do |t|
    t.string   "area",           :limit => 100
    t.string   "keyword",        :limit => 100
    t.integer  "city_id",                       :null => false
    t.integer  "member_id"
    t.integer  "hot_spot_count"
    t.boolean  "from_mobile"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :default => "", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "subscription_message_sent_logs", :force => true do |t|
    t.integer  "subscription_message_id",                    :null => false
    t.integer  "member_id",                                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "sent",                    :default => false
    t.integer  "retry_times",             :default => 0
  end

  create_table "subscription_messages", :force => true do |t|
    t.integer  "subscription_topic_id",                                :null => false
    t.integer  "content_object_id",                                    :null => false
    t.string   "content_object_type",   :limit => 100, :default => "", :null => false
    t.boolean  "sent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscription_topics", :force => true do |t|
    t.string  "name",         :limit => 100, :default => "", :null => false
    t.integer "subject_id"
    t.string  "subject_type", :limit => 100
    t.boolean "sent_all"
  end

  create_table "taboo_words", :force => true do |t|
    t.string  "word",   :limit => 30,  :default => "",   :null => false
    t.string  "regexp", :limit => 180
    t.boolean "active",                :default => true
  end

  create_table "tags", :force => true do |t|
    t.string "tag", :limit => 90, :default => "", :null => false
  end

  create_table "topic_expos", :force => true do |t|
    t.integer  "topic_id"
    t.string   "square_ids_family"
    t.string   "square_ids_sweet"
    t.string   "square_ids_grandparent"
    t.string   "square_ids_child"
    t.string   "traffic_title"
    t.string   "traffic_content"
    t.string   "exhibition_title_family"
    t.string   "exhibition_title_sweet"
    t.string   "exhibition_title_grandparent"
    t.string   "exhibition_title_child"
    t.string   "travel_line_title_family"
    t.string   "travel_line_title_sweet"
    t.string   "travel_line_title_grandparent"
    t.string   "travel_line_title_child"
    t.string   "travel_line_family",            :limit => 1000
    t.string   "travel_line_sweet",             :limit => 1000
    t.string   "travel_line_grandparent",       :limit => 1000
    t.string   "travel_line_child",             :limit => 1000
    t.string   "expo_guide"
    t.string   "tiexin_guide"
    t.string   "food_ids"
    t.string   "tiexin_sbx"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topics", :force => true do |t|
    t.string   "title",       :limit => 100,  :default => "", :null => false
    t.string   "banner",      :limit => 500
    t.string   "summary",     :limit => 3000
    t.string   "cover_pic",   :limit => 500
    t.string   "template",    :limit => 100
    t.datetime "expire_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "city_id"
  end

  create_table "traffic_lines", :force => true do |t|
    t.string  "name_zh_cn",           :limit => 300
    t.string  "name_en",              :limit => 300
    t.integer "line_type",                            :default => 1, :null => false
    t.string  "introduction_zh_cn",   :limit => 3000
    t.string  "introduction_en",      :limit => 3000
    t.integer "city_id"
    t.integer "fid"
    t.string  "operation_time_zh_cn", :limit => 600
    t.string  "operation_time_en",    :limit => 600
  end

  create_table "traffic_stops", :force => true do |t|
    t.integer "traffic_line_id",                :null => false
    t.integer "position",        :default => 0, :null => false
    t.integer "hot_spot_id",                    :null => false
  end

  create_table "votes", :force => true do |t|
    t.integer  "member_id",                                 :null => false
    t.string   "target_type", :limit => 30, :default => "", :null => false
    t.integer  "target_id",                                 :null => false
    t.integer  "vote"
    t.datetime "created_at"
  end

  create_table "zoom_levels", :force => true do |t|
    t.integer  "layout_map_id",                  :null => false
    t.integer  "width"
    t.integer  "height"
    t.integer  "scale",           :default => 1, :null => false
    t.string   "map_file"
    t.integer  "map_file_width"
    t.integer  "map_file_height"
    t.datetime "created_at"
  end

end
