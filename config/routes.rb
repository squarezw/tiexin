ActionController::Routing::Routes.draw do |map|
  map.blog_root '', :controller => 'blogs' , :action => 'show', :conditions => { :subdomain2 =>  "blog" }
  
  map.resources :blogs, :member => {:about=>:get }, :has_many => [:articles, :pictures, :rss_sources]
  map.resources :rss_sources,:collection => { :info=>:get,  :syndicate=>:get}
  
  map.namespace :admin do |admin|
    admin.resources :channels
    admin.resources :recommended_tags
    admin.resources :partners
    admin.resources :campaigns
    admin.resources :topics, 
                    :collection => { :expo => :get, :related_articles=>:get, :related_posts=>:get, :related_hot_spots=>:get, :recommend => :post},
                    :member=> {:publish => :post, :cancel_recommend => :post}
    admin.resources :gifts  
    admin.resources :gift_orders
    admin.resources :error_logs
    admin.resources :discount_coupons, :member=>{:approve=>:post, :disapprove=>:post}
    admin.resources :coupon_templates
    admin.resources :hotels, :has_many => [:hotel_rooms], :collection => {:search_hot_spot => :get}
    admin.resources :districts
    admin.resources :articles, :member=>{:approve=>:post, :disapprove=>:post }
    admin.resources :hot_topics
    admin.resources :friend_links
    admin.resources :data_events,:collection => { :related_hot_spots=>:get, :insert_related =>:post}
  end
  
  map.resources :topics, :collection => {:expo => :get, :event_calendar => :get}
  
  map.namespace :merchant do |merchant|
    merchant.resources :discount_coupons, :member=>{ :submit=>:post, :preview=>:get }
  end

  map.namespace :campaign do |campaign|
    campaign.resources :gifts, :collection => { :available_point=>:get }, :member=>{:photos=>:get}
    campaign.resources :gift_orders, :member=> { :confirm=>:get, :deliver=>:get }
  end
  
  map.namespace :partner do |partner|
    partner.resources :sessions
    partner.resources :gift_orders, :collection=> { :export=> :get }
  end
  
  map.resources :cities, 
                :member => { :bind=>:post, :map=>:get, :auto_complete_for_area=>:post, :event_calendar=>:get },
                :has_many => [:map_levels, :hot_spot_categories, :areas, :articles, :districts] do |city|
      city.resources :channels, 
                     :member=>{:brands=>:get, 
                               :tags=>:get, 
                               :contracted_hot_spots=>:get,
                               :owner_recommended_products => :get,
                               :promotions=> :get } 
      city.resources :city_events, 
                     :collection=>{:for_date => :get, :for_month=> :get, :tags=>:get}
      city.resources :topics
      
      city.resources :brands, :member=>{:hot_spots=>:get}
      city.resources :districts
  end
  
  map.resources :channel_daily_contents,
                :path_prefix=>'channels/:channel_id'

  map.theme_images "/themes/:theme/images/*filename", :controller=>'theme', :action=>'images'
  map.theme_stylesheets "/themes/:theme/stylesheets/*filename", :controller=>'theme', :action=>'stylesheets'  
  map.theme_javascript "/themes/:theme/javascript/*filename", :controller=>'theme', :action=>'javascript'
  
  map.connect 'cities/:id/search.:format', :controller=>'search', :action=>'search', :format=>'html'
  map.connect 'cities/:id/search_all/:category', :controller=>'search', :action=>'search_all'
  map.connect 'cities/:id/advanced_search', :controller => 'search', :action=>'advanced_search'
  map.connect 'cities/:id/search_near_hot_spot/:hot_spot_id.:format', :controller=>'search', :action=>'search_nearby'
  map.connect 'cities/:id/search/brand/:brand_id', :controller=>'search', :action=>'show_brand' 
  map.connect 'cities/:id/search/tag', :controller=>'search', :action=>'show_tag'
             
  map.resources :hot_spots, 
                :collection=>{ :new_from_map => :get },
                :has_many=>[:nearby_hot_spots, :traffic_lines],
                :member=>{:refresh_tree_node_and_marker => :get,
                          :show_marker_info => :get,
                          :move => :post,
                          :access_traffic_lines => :get,
                          :edit_brand => :get,
                          :update_brand => :put,
                          :marker => :get,
                          :articles => :get,
                          :to_recommend => :get,
                          :recommend => :post,
                          :capabilities => :get,
                          :basic_information => :get,
                          :products => :get,
                          :brand => :get,
                          :detail => :get,
                          :gmap => :get
                        } do |hot_spots|
    hot_spots.resources :tags,:collection => {:tag_description => :get, :tag_hot_spots => :get}
    hot_spots.resources :inner_hot_spots, :collection => { :search_for_add=>:post, :search=>:get }, :member=>{ :add=>:post } 
    hot_spots.resources :revises,
                        :member => {:check=>:put}
    hot_spots.resources :scores
    hot_spots.resources :favorites, :controller=>'favorites'    
  end
  
  map.resources :tags,:collection => {:tag_of_hot_spots => :get}
  
  map.resources :coupons, :member=>{:apply=>:post}
  
  map.resources :received_coupons, :collection=>{:print=>:post}
  
  map.resources :revises,
                :controller => "admin/revises",
                :path_prefix => 'admin',
                :name_prefix => 'manage_'
                
  map.resources :products,
                :path_prefix=>'vendor/:vendor_type/:vendor_id'

  map.connect '/cities/:city_id/areas/:id/hot_spot_category/:category_id', :controller => 'areas', :action => 'hot_spot_category'
    
  
  map.resources :hot_spot_categories, :controller=>'admin/hot_spot_categories',
                :path_prefix=>'admin',
                :name_prefix=>'manage_',
                :member=>{:merge_or_move => :post},
                :collection=> { :category_tree => :get}
  
  map.resources :hot_spot_categories,
                :member=>{:children=>:get } do |hot_spot_categories|
   hot_spot_categories.resources :promotions
  end
                
  map.resources :hot_spots,
                :controller=>'admin/hot_spots',
                :path_prefix=>'admin',
                :name_prefix=>'manage_',
                :collection=> { :approve => :post,
                                :waiting_approve=>:get,
                                :waiting_recommend=>:get,
                                :waiting_recommend_for_brand => :get,
                                :waiting_recommend_for_tag => :get,
                                :recommend_for_brand => :post,
                                :recommend_for_tag => :get,
                                :nearby_option => :get,
                                :nearby => :post,
                                :recommend => :post,
                                :cancel_recommend => :post
                              },
                :member => { :approve => :post, :recommend => :post, :cancel_recommend => :post,
                              :recommend_ontop => :post, :cancel_recommend_ontop => :post} do |hot_spots|
    hot_spots.resources :merges, :controller=>'admin/hot_spot_merges',
                :collection => { :search_target => :post, :preview=>:get }
  end
  
 
  map.resources :layout_maps, 
               :path_prefix=>'layoutable/:layoutable_class/:layoutable_id',
               :collection=> {:to_search => :get, :search=>:post, :category_navigator => :get }
  
  map.resources :areas,
                :controller=>'admin/areas',
                :path_prefix=>'admin',
                :name_prefix=>'manage_',
                :member => { :show_marker_info => :get, 
                             :reposition => :post} 
  
  map.resources :positions, 
                :path_prefix=>'layout_map/:layout_map_id',
                :member => { :move => :post}
  
  map.resources :traffic_lines
  
  map.resources :manage_cities, :controller=>'admin/cities',
                :path_prefix=>'admin'
  
  map.resources :manage_layout_maps, :controller => 'admin/layout_maps',
                :path_prefix=>'admin/hot_spot/:hot_spot_id'
                
  map.resources :zoom_levels, :controller=>'admin/zoom_levels',
                :path_prefix=>'admin/layout_map/:layout_map_id',
                :name_prefix => 'manage_'  
                
  map.resources :photos, 
                :path_prefix=>'photo/:owner_type/:owner_id',
                :collection => { :random => :get }
                
  map.resources :comments,
                :path_prefix=>'commentable/:commentable_type/:commentable_id',
                :member => { :quote=>:get, :disagree=>:post, :agree=>:post }    
                
  map.resources :waiting_check_comments,
                :controller => 'admin/waiting_check_comments', 
                :path_prefix=>'admin',
                :member => { :pass => :post } 
                
  map.resources :taboo_words,
                :controller => 'admin/taboo_words',
                :collection => { :test => :post }  
  
  map.resources :members,
                :has_many => :pictures,
                :collection => { :search => :post, 
                                 :search => :get,
                                 :reset_password=>:post, 
                                 :forget_password=>:get,
                                 :request_confirmation_code=>:get,
                                 :resend_confirmation_code=>:post ,
                                 :check_password=>:post }, 
                :member => { :confirm_registration => :get,
                             :grant_admin => :post,
                             :revoke_admin => :post,
                             :grant_staff => :post,
                             :revoke_staff => :post,
                             :lock => :post,
                             :unlock => :post,
                             :detail => :get,
                             :to_invite => :get,
                             :invite => :post,
                             :add_as_friend => :post,
                             :open_option => :post,
                             :owned_hot_spots => :get,
                             :owned_brands => :get,
                             :created_brands => :get,
                             :owned_privileges =>:get,
                             :modify_privileges => :post,
                             :capabilities => :get
                           } do |member|
      member.resources :created_hot_spots, :controller=>'member_hot_spots'
      member.resources :posted_comments, :controller => 'member_comments' 
      member.resources :posted_revises, :controller => 'member_revises'
      member.resources :posted_photos, :controller => 'member_photos'
      member.resources :posted_products, :controller => 'member_products'      
      member.resources :posted_tags, :controller=>'member_hot_spot_tags', :collection=> {:hot_spots_has_tag => :get}
      member.resources :promotions, :controller=>'member_promotions'
      member.resources :messages, :controller=>'member_messages', :collection=> {:sent => :get, :received => :get, :has_not_read => :get}
      member.resources :articles, :controller=>'articles'
      member.resources :posts, :controller=>'member_posts'
      member.resources :folders, :controller=>'folders' do |folders|
        folders.resources :articles, :controller=>'articles'
      end
      member.resources :favorites, :controller=>'favorites'
  end
  
  map.resources :mobile_brands,
                  :has_many => :mobile_models,
                  :controller => 'admin/mobile_brands',
                  :path_prefix => 'admin',
                  :name_prefix=>'manage_'
                 
              
  map.resources :mobile_models,
                  :controller => 'admin/mobile_models',
                  :path_prefix => 'admin',
                  :name_prefix=>'manage_'
                
  map.resources :navi_stars,
                  :controller => 'admin/navi_stars',
                  :path_prefix => 'admin',
                  :name_prefix=>'manage_',
                  :collection=>{:check_update=>:get}
  
  map.resources :mobile_oss,
                  :controller => 'admin/mobile_oss',
                  :path_prefix => 'admin',
                  :name_prefix=>'manage_'
  
  map.resources :articles, :member=> {:recommend => :post, :cancel_recommend => :post}
  
  map.resources :recommended_hot_spots
  
  map.resources :friends, :collection=>{:pending=>:get, :quick_add=>:post}

  map.resources :promotions,
                  :path_prefix=>'vendor/:vendor_type/:vendor_id'
                
  map.resources :events,
                :path_prefix=>'vendor/:vendor_type/:vendor_id',
                :collection=>{:on_date => :get, :show_month=> :get}
                
  map.resources :traffic_lines,
               :path_prefix => 'admin',
               :name_prefix => 'manage_', 
               :controller => 'admin/traffic_lines',
               :collection => { :search => :get },
               :member => { :search_hot_spots => :post }  do |line|
      line.resources :stops, :controller=>'admin/traffic_stops', 
                     :collection => { :sort => :post } 
  end
               
  map.resources :sessions                
  
  map.resources :bulletins

  map.resources :bulletins,
                :controller => 'admin/bulletins',
                :path_prefix => 'admin',
                :name_prefix => 'manage_',
                :member=> {:publish=>:post}
              
  map.resources :brands,
                :member => { :articles => :get, :map=>:get, :capabilities=>:get, :hot_spots=>:get, :products=>:get }
  
  map.resources :brands,
                :new => {:merge => :post},
                :controller => "admin/brands",
                :path_prefix => 'admin',
                :name_prefix => 'manage_',
                :collection => { :search => :get,
                :auto_complete_for_brand_name_zh_cn => :get,
                :auto_complete_for_brand_name_en => :get
                },
                :member => {
                  :to_add_hot_spot => :post,
                  :add_hot_spot => :post,
                  :remove_hot_spot => :post
                } do |brands|
    brands.resources :merges, :controller=>'admin/brand_merges',
                :collection => { :search_target => :post, :preview=>:get }
  end

  map.resources :owner_applications,
                :controller=>'admin/owner_applications',
                :path_prefix => 'admin'

  map.resources :forums,:member => {:add_blacklist => :get, :to_add_blacklist => :post, :del_blacklist => :post} do |forum|
    forum.resources :posts,
                    :collection=>{:set_option=>:post, :auto_complete_for_tag_tag => :get},
                    :member=>{:quote=>:get,
                              :vote=>:post } do |post|
      post.resources :replies, 
                     :member=>{:quote=>:get, :vote=>:post}      
    end
  end
  
  map.resources :forums,
                :controller=>'admin/forums',
                :path_prefix=>'admin',
                :name_prefix=>'manage_',
                :collection => {:moderator => :get, :blacklist => :get},
                :member => {:add_moderator => :get, :to_add_moderator => :post, :del_moderator => :post}
  
  map.resources :posts,
                :controller=>'admin/posts',
                :path_prefix=>'admin',
                :name_prefix=>'manage_',                
                :member=>{ :put_to_top => :post,
                           :remove_from_top => :post,
                           :lock => :post,
                           :remove_lock => :post,
                           :move => :post,
                           :check => :post,
                           :show_in_homepage => :post }
  map.resources :replies,
                :controller=>'admin/replies',
                :path_prefix=>'admin',
                :name_prefix=>'manage_',
                :member=>{ :check=> :post }

  map.resources :hotels, :collection => {:categories => :get, :search => :get, :contact => :get}, :has_many => [:hotel_rooms]
  
  map.resources :hotel_rooms
  
  map.resources :hotel_reservations
  
  map.logout    '/logout', :controller=>'sessions', :action=>'destroy'
                  
  map.connect 'map_tiles/:x/:y', :controller=>'map_tiles', :action=>'show' 
  
  map.captcha_image '/captcha.jpg', :controller=>'captcha'  

  map.main '', :controller => "cities", :action=>'index'
  
  map.static '/static/:action', :controller=>'static'
  
#  map.connect 'main/fast_search', :controller=>'main', :action=>'fast_search'  
#  map.connect 'main/:action/:id', :controller=>'main', :action=>'index', :id => nil 
  
#  map.connect 'main/traffic_line/:id', :controller=>'main', :action=>'show_traffic_line'      
  
  map.map_blocks 'map_blocks/:city_id/:level/:x/:y', :controller => 'map_blocks', :action=>'show'
  
  map.resources :operation_logs,
                :path_prefix=>'object/:object_type/:object_id',
                :name_prefix=>'object_'
                
  map.resources :operation_logs
  
  map.search '/search', :controller=>'hot_spots', :action => 'search'
  
  map.search '/language/:lang', :controller=>'language', :action=>'select_lang'

  map.connect '/master_data/:action/:id.:format', :controller => 'master_data' 
  
  map.connect '/admin/statistics/:action/:scope', :controller=>'admin/statistics', 
          :defaults=>{:action=>'index', :scope=>nil}
          
  map.mobile_download '/download/:action', :controller=>'download'
  
  map.download '/download/:platform/:release/:major/:minor.:suffix', :controller=>'download', :action=>'download'
  
  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'
    
  # Install the default route as the lowest priority.
  # map.connect ':controller/:action/:id.:format'
 map.connect ':controller/:action/:id'
end
