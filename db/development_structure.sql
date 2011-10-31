CREATE TABLE `access_logs` (
  `id` int(11) NOT NULL auto_increment,
  `member_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `mobile` tinyint(1) default NULL,
  `locale` varchar(5) default NULL,
  `remote_ip` varchar(15) default NULL,
  `controller` varchar(256) default NULL,
  `action` varchar(256) default NULL,
  `method` varchar(10) default NULL,
  `user_agent` varchar(1024) default NULL,
  `referer` varchar(4096) default NULL,
  `request_uri` varchar(4096) default NULL,
  `response_status` varchar(20) default NULL,
  `browser` varchar(50) default NULL,
  `browser_version` varchar(50) default NULL,
  `from_robot` tinyint(1) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_access_logs_on_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=50932 DEFAULT CHARSET=utf8;

CREATE TABLE `areas` (
  `id` int(11) NOT NULL auto_increment,
  `city_id` int(11) NOT NULL,
  `name_en` varchar(60) default NULL,
  `name_zh_cn` varchar(60) default NULL,
  `nw_x` int(11) default NULL,
  `nw_y` int(11) default NULL,
  `width` int(11) default NULL,
  `height` int(11) default NULL,
  `center_x` int(11) default NULL,
  `center_y` int(11) default NULL,
  `visit_count` int(11) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8;

CREATE TABLE `articles` (
  `id` int(11) NOT NULL auto_increment,
  `subject` varchar(3000) NOT NULL,
  `member_id` int(11) NOT NULL,
  `folder_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `read_times` int(11) NOT NULL default '0',
  `comments_count` int(11) default '0',
  `brand_id` int(11) default NULL,
  `content` text,
  `summary` varchar(1000) default NULL,
  `rss_source_id` int(11) default NULL,
  `link` varchar(500) default NULL,
  `synch_date` datetime default NULL,
  `post_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8;

CREATE TABLE `articles_hot_spots` (
  `article_id` int(11) NOT NULL,
  `hot_spot_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `blogs` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(30) NOT NULL,
  `simple_name` varchar(30) NOT NULL,
  `picture` varchar(50) default NULL,
  `skin_id` int(11) NOT NULL default '1',
  `owner_id` int(11) NOT NULL,
  `read_times` int(11) NOT NULL default '0',
  `read_time` datetime default NULL,
  `read_ip` varchar(20) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

CREATE TABLE `brands` (
  `id` int(11) NOT NULL auto_increment,
  `name_zh_cn` varchar(300) default NULL,
  `name_en` varchar(300) default NULL,
  `pic` varchar(255) default NULL,
  `intro` varchar(3000) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `creator_id` int(11) default NULL,
  `home_page` varchar(1000) default NULL,
  `visit_count` int(11) default '0',
  `owner_id` int(11) default NULL,
  `hot_spot_category_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;

CREATE TABLE `bulletins` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(90) NOT NULL,
  `language` varchar(10) NOT NULL default 'zh_cn',
  `content` text,
  `expire_date` date default NULL,
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

CREATE TABLE `campaigns` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(300) NOT NULL,
  `trigger` int(11) NOT NULL default '1',
  `bonus_experience` int(11) default '0',
  `bonus_credit` int(11) default '0',
  `expire_date` date NOT NULL,
  `confirm_message` varchar(1000) NOT NULL,
  `description` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

CREATE TABLE `channels` (
  `id` int(11) NOT NULL auto_increment,
  `hot_spot_category_id` int(11) NOT NULL,
  `forum_id` int(11) NOT NULL,
  `icon` varchar(100) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;

CREATE TABLE `cities` (
  `id` int(11) NOT NULL auto_increment,
  `name_en` varchar(180) default NULL,
  `name_zh_cn` varchar(180) default NULL,
  `width` int(11) default NULL,
  `height` int(11) default NULL,
  `x0` decimal(12,2) default NULL,
  `y0` decimal(12,2) default NULL,
  `start_point_x` int(11) default NULL,
  `start_point_y` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `photo` varchar(100) default NULL,
  `weather_code` varchar(2048) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

CREATE TABLE `cities_events` (
  `city_id` int(11) NOT NULL,
  `event_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `comments` (
  `id` int(11) NOT NULL auto_increment,
  `commentable_type` varchar(255) NOT NULL,
  `commentable_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `content` text,
  `status` int(11) default '1',
  `agree` int(11) default '0',
  `disagree` int(11) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=77 DEFAULT CHARSET=utf8;

CREATE TABLE `contents` (
  `id` int(11) NOT NULL auto_increment,
  `post_id` int(11) NOT NULL,
  `content` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;

CREATE TABLE `download_logs` (
  `id` int(11) NOT NULL auto_increment,
  `platform` varchar(50) NOT NULL,
  `version` varchar(10) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

CREATE TABLE `events` (
  `id` int(11) NOT NULL auto_increment,
  `vendor_type` varchar(20) default NULL,
  `vendor_id` int(11) default NULL,
  `member_id` int(11) default NULL,
  `summary_en` varchar(3000) NOT NULL,
  `summary_zh_cn` varchar(3000) NOT NULL,
  `content_en` text,
  `content_zh_cn` text,
  `begin_date` date default NULL,
  `end_date` date default NULL,
  `banner` varchar(500) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `allcity` tinyint(1) default '0',
  `post` varchar(500) default NULL,
  `type` varchar(20) default NULL,
  `global_id` varchar(255) default NULL,
  `reference_url` varchar(2048) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8;

CREATE TABLE `folders` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(90) NOT NULL,
  `member_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

CREATE TABLE `forums` (
  `id` int(11) NOT NULL auto_increment,
  `order_sequence` int(11) NOT NULL,
  `name` varchar(150) default NULL,
  `description` varchar(3000) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

CREATE TABLE `friends` (
  `id` int(11) NOT NULL auto_increment,
  `owner_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `pending` tinyint(1) default '1',
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8;

CREATE TABLE `gift_order_items` (
  `id` int(11) NOT NULL auto_increment,
  `gift_order_id` int(11) NOT NULL,
  `gift_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL default '1',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8;

CREATE TABLE `gift_orders` (
  `id` int(11) NOT NULL auto_increment,
  `member_id` int(11) NOT NULL,
  `deliver_method` int(11) NOT NULL,
  `payment_method` int(11) NOT NULL,
  `city` varchar(300) default NULL,
  `address` varchar(900) default NULL,
  `post_code` varchar(10) default NULL,
  `phone_number` varchar(15) default NULL,
  `phone_number2` varchar(15) default NULL,
  `name` varchar(300) default NULL,
  `used_experience` int(11) NOT NULL default '0',
  `used_credit` int(11) NOT NULL default '0',
  `cash` float NOT NULL default '0',
  `status` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `certificate_type` varchar(90) default NULL,
  `certificate_no` varchar(30) default NULL,
  `confirmed_at` datetime default NULL,
  `partner_id` int(11) default NULL,
  `plan_fetch_date` date default NULL,
  `recommender` varchar(100) default NULL,
  `delivered_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8;

CREATE TABLE `gifts` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(300) NOT NULL,
  `experience` int(11) NOT NULL default '0',
  `credit` int(11) NOT NULL default '0',
  `cash` int(11) NOT NULL default '0',
  `total_quantity` int(11) NOT NULL default '-1',
  `sold_quantity` int(11) NOT NULL default '0',
  `booked_quantity` int(11) NOT NULL default '0',
  `delivery_fee` int(11) NOT NULL default '0',
  `on_sale` tinyint(1) NOT NULL default '1',
  `picture` varchar(100) default NULL,
  `description` text NOT NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `reference_price` float default NULL,
  `reference_url` varchar(300) default NULL,
  `support_deliver_method` varchar(255) default NULL,
  `partner_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

CREATE TABLE `hot_spot_access_logs` (
  `id` int(11) NOT NULL auto_increment,
  `member_id` int(11) default NULL,
  `hot_spot_id` int(11) NOT NULL,
  `created_at` datetime default NULL,
  `from_mobile` tinyint(1) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1539 DEFAULT CHARSET=latin1;

CREATE TABLE `hot_spot_categories` (
  `id` int(11) NOT NULL auto_increment,
  `name_en` varchar(60) default NULL,
  `name_zh_cn` varchar(60) default NULL,
  `parent_id` int(11) default NULL,
  `icon` varchar(255) default NULL,
  `icon_mime_type` varchar(255) default NULL,
  `icon_filesize` varchar(255) default NULL,
  `traffic_stop_type` int(11) default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `map_icon` varchar(255) default NULL,
  `big_icon` varchar(255) default NULL,
  `order_weight` int(11) default '0',
  `keyword` varchar(300) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=185 DEFAULT CHARSET=utf8;

CREATE TABLE `hot_spot_scores` (
  `id` int(11) NOT NULL auto_increment,
  `hot_spot_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `quality` int(11) default '0',
  `service` int(11) default '0',
  `environment` int(11) default '0',
  `price` int(11) default '0',
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

CREATE TABLE `hot_spot_tags` (
  `id` int(11) NOT NULL auto_increment,
  `tag` varchar(255) default NULL,
  `description` varchar(3000) default NULL,
  `member_id` int(11) default NULL,
  `hot_spot_id` int(11) NOT NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `idx_hot_spot_tag` (`tag`),
  KEY `idx_hot_spot_tags_hot_spot_id_tag` (`hot_spot_id`,`tag`)
) ENGINE=InnoDB AUTO_INCREMENT=119 DEFAULT CHARSET=utf8;

CREATE TABLE `hot_spots` (
  `id` int(11) NOT NULL auto_increment,
  `city_id` int(11) NOT NULL,
  `hot_spot_category_id` int(11) default NULL,
  `name_en` varchar(180) default NULL,
  `name_zh_cn` varchar(180) default NULL,
  `address_en` varchar(180) default NULL,
  `address_zh_cn` varchar(180) default NULL,
  `x` int(11) default NULL,
  `y` int(11) default NULL,
  `phone_number` varchar(120) default NULL,
  `introduction_en` varchar(3000) default NULL,
  `introduction_zh_cn` varchar(3000) default NULL,
  `creator_id` int(11) NOT NULL,
  `approved` tinyint(1) default NULL,
  `created_at` datetime default NULL,
  `comments_count` int(11) default '0',
  `price_level` int(11) default NULL,
  `price_memo` varchar(600) default NULL,
  `parking_slot` int(11) default NULL,
  `container_id` int(11) default NULL,
  `operation_time_zh_cn` varchar(600) default NULL,
  `operation_time_en` varchar(600) default NULL,
  `home_page` varchar(450) default NULL,
  `ref_id` int(11) default NULL,
  `visit_count` int(11) default '0',
  `brand_id` int(11) default NULL,
  `owner_id` int(11) default NULL,
  `quality_score` int(11) default '0',
  `service_score` int(11) default '0',
  `environment_score` int(11) default '0',
  `price_score` int(11) default '0',
  `score` float default '0',
  `updated_at` datetime default NULL,
  `score_count` int(11) default '0',
  PRIMARY KEY  (`id`),
  KEY `index_hot_spots_on_created_at` (`created_at`),
  KEY `index_hot_spots_on_x_and_y` (`x`,`y`),
  KEY `idx_hot_spots_hot_spot_category_id` (`hot_spot_category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=131056 DEFAULT CHARSET=utf8;

CREATE TABLE `hot_spots_members` (
  `hot_spot_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `invitations` (
  `id` int(11) NOT NULL auto_increment,
  `member_id` int(11) NOT NULL,
  `mail` varchar(255) NOT NULL,
  `add_friends` tinyint(1) default '1',
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

CREATE TABLE `layout_maps` (
  `id` int(11) NOT NULL auto_increment,
  `name_en` varchar(60) default NULL,
  `name_zh_cn` varchar(60) default NULL,
  `layoutable_type` varchar(255) NOT NULL,
  `layoutable_id` int(11) NOT NULL,
  `introduction_zh_cn` varchar(3000) default NULL,
  `introduction_en` varchar(3000) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;

CREATE TABLE `map_levels` (
  `id` int(11) NOT NULL auto_increment,
  `city_id` int(11) NOT NULL,
  `no` int(11) NOT NULL,
  `scale` float NOT NULL,
  `row` int(11) NOT NULL,
  `column` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=latin1;

CREATE TABLE `member_privileges` (
  `id` int(11) NOT NULL auto_increment,
  `member_id` int(11) NOT NULL,
  `privilege` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8;

CREATE TABLE `members` (
  `id` int(11) NOT NULL auto_increment,
  `login_name` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `mail` varchar(200) default NULL,
  `nick_name` varchar(255) default NULL,
  `created_at` datetime NOT NULL,
  `is_admin` tinyint(1) NOT NULL default '0',
  `confirmed` tinyint(1) default '0',
  `confirm_code` varchar(100) default NULL,
  `favorite_lang` varchar(5) default NULL,
  `logo` varchar(255) default NULL,
  `logo_mime_type` varchar(50) default NULL,
  `mobile_phone` varchar(20) default NULL,
  `city_for_mobile` int(11) default NULL,
  `locked_until` datetime default NULL,
  `experience` int(11) default '0',
  `credit` int(11) default '0',
  `is_merchant` tinyint(1) default '0',
  `inviter_id` int(11) default NULL,
  `invitation_id` int(11) default NULL,
  `favorite_open_option` int(11) default '1',
  `is_staff` tinyint(1) default '0',
  `used_experience` int(11) default '0',
  `used_credit` int(11) default '0',
  `city` varchar(200) default NULL,
  `address` varchar(900) default NULL,
  `post_code` varchar(10) default NULL,
  `phone_number2` varchar(15) default NULL,
  `real_name` varchar(300) default NULL,
  `certificate_type` varchar(90) default NULL,
  `certificate_no` varchar(30) default NULL,
  `mobile_register` tinyint(1) default '0',
  `machine_code` varchar(100) default NULL,
  `mail_confirm_code` varchar(255) default NULL,
  `mail_confirm` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1;

CREATE TABLE `members_recommended_hot_spots` (
  `member_id` int(11) NOT NULL,
  `recommended_hot_spot_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `messages` (
  `id` int(11) NOT NULL auto_increment,
  `from_id` int(11) NOT NULL,
  `to_id` int(11) NOT NULL,
  `title` varchar(300) NOT NULL,
  `content` varchar(3000) default NULL,
  `readed` tinyint(1) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `sender_deleted` tinyint(1) default '0',
  `receiver_deleted` tinyint(1) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=70 DEFAULT CHARSET=utf8;

CREATE TABLE `mobile_brands` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `logo` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

CREATE TABLE `mobile_models` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `picture` varchar(255) default NULL,
  `mobile_brand_id` int(11) default NULL,
  `mobile_os_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

CREATE TABLE `mobile_os` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

CREATE TABLE `navi_photos` (
  `id` int(11) NOT NULL auto_increment,
  `owner_type` varchar(255) NOT NULL,
  `owner_id` int(11) NOT NULL,
  `subject` varchar(300) default NULL,
  `photo` varchar(255) default NULL,
  `uploader_id` int(11) NOT NULL,
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=390 DEFAULT CHARSET=utf8;

CREATE TABLE `navi_stars` (
  `id` int(11) NOT NULL auto_increment,
  `release` int(11) NOT NULL,
  `major` int(11) NOT NULL,
  `minor` int(11) NOT NULL,
  `suffix` varchar(255) default NULL,
  `filename` varchar(255) default NULL,
  `mobile_os_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `minimum_release` int(11) NOT NULL,
  `minimum_major` int(11) NOT NULL,
  `minimum_minor` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

CREATE TABLE `operation_logs` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime NOT NULL,
  `operation` varchar(50) NOT NULL,
  `related_object_type` varchar(50) default NULL,
  `related_object_id` int(11) default NULL,
  `message_key` varchar(2048) default NULL,
  `memo` varchar(3000) default NULL,
  `message_parameters` text,
  `member_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;

CREATE TABLE `owner_applications` (
  `id` int(11) NOT NULL auto_increment,
  `target_type` varchar(30) NOT NULL,
  `target_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `status` int(11) NOT NULL default '0',
  `admin_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `opinion` varchar(300) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8;

CREATE TABLE `partners` (
  `id` int(11) NOT NULL auto_increment,
  `code` varchar(8) NOT NULL,
  `name` varchar(300) NOT NULL,
  `phone_number` varchar(20) NOT NULL,
  `contact_person` varchar(60) default NULL,
  `mail` varchar(50) default NULL,
  `password_hash` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

CREATE TABLE `pictures` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(30) NOT NULL,
  `photo` varchar(255) default NULL,
  `tag_list` varchar(100) default NULL,
  `description` varchar(1000) default NULL,
  `read_times` int(11) NOT NULL default '0',
  `member_id` int(11) NOT NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `positions` (
  `id` int(11) NOT NULL auto_increment,
  `hot_spot_id` int(11) NOT NULL,
  `layout_map_id` int(11) NOT NULL,
  `x` double NOT NULL,
  `y` double NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8;

CREATE TABLE `posts` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(300) NOT NULL,
  `member_id` int(11) NOT NULL,
  `forum_id` int(11) NOT NULL,
  `created_at` datetime default NULL,
  `last_replied_at` datetime default NULL,
  `read_times` int(11) NOT NULL default '0',
  `vote_result` int(11) NOT NULL default '0',
  `always_on_top` tinyint(1) NOT NULL default '0',
  `lock` tinyint(1) NOT NULL default '0',
  `check_status` int(11) NOT NULL default '0',
  `good_score` int(11) NOT NULL default '0',
  `hidden_score` int(11) NOT NULL default '0',
  `water_score` int(11) NOT NULL default '0',
  `attachment` varchar(255) default NULL,
  `replies_count` int(11) NOT NULL default '0',
  `updated_at` datetime default NULL,
  `deleted` tinyint(1) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;

CREATE TABLE `products` (
  `id` int(11) NOT NULL auto_increment,
  `vendor_id` int(11) default NULL,
  `name_en` varchar(300) default NULL,
  `name_zh_cn` varchar(300) default NULL,
  `official` tinyint(1) NOT NULL default '0',
  `introduction_en` varchar(3000) default NULL,
  `introduction_zh_cn` varchar(3000) default NULL,
  `photo` varchar(255) default NULL,
  `creator_id` int(11) default NULL,
  `last_updater_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `vendor_type` varchar(20) default NULL,
  `price` varchar(100) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=186 DEFAULT CHARSET=utf8;

CREATE TABLE `recommended_hot_spots` (
  `id` int(11) NOT NULL auto_increment,
  `member_id` int(11) NOT NULL,
  `hot_spot_id` int(11) NOT NULL,
  `readed` tinyint(1) NOT NULL default '0',
  `created_at` datetime default NULL,
  `last_recommended_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

CREATE TABLE `recommended_tags` (
  `id` int(11) NOT NULL auto_increment,
  `tag` varchar(255) NOT NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

CREATE TABLE `replies` (
  `id` int(11) NOT NULL auto_increment,
  `member_id` int(11) NOT NULL,
  `post_id` int(11) NOT NULL,
  `position` int(11) default NULL,
  `created_at` datetime default NULL,
  `last_replied_at` datetime default NULL,
  `vote_result` int(11) NOT NULL default '0',
  `check_status` int(11) default NULL,
  `good_score` int(11) NOT NULL default '0',
  `hidden_score` int(11) NOT NULL default '0',
  `water_score` int(11) NOT NULL default '0',
  `attachment` varchar(255) default NULL,
  `content` text,
  `updated_at` datetime default NULL,
  `deleted` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8;

CREATE TABLE `revises` (
  `id` int(11) NOT NULL auto_increment,
  `hot_spot_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `suggestion` varchar(2048) default NULL,
  `remark` varchar(2048) default NULL,
  `admin_id` int(11) default NULL,
  `processed_at` datetime default NULL,
  `created_at` datetime default NULL,
  `status` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8;

CREATE TABLE `road_segments` (
  `id` int(11) NOT NULL auto_increment,
  `road_id` int(11) NOT NULL,
  `start_x` int(11) NOT NULL,
  `start_y` int(11) NOT NULL,
  `end_x` int(11) NOT NULL,
  `end_y` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=99323 DEFAULT CHARSET=utf8;

CREATE TABLE `roads` (
  `id` int(11) NOT NULL auto_increment,
  `city_id` int(11) NOT NULL,
  `name_zh_cn` varchar(300) default NULL,
  `name_en` varchar(300) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7303 DEFAULT CHARSET=utf8;

CREATE TABLE `rss_sources` (
  `id` int(11) NOT NULL auto_increment,
  `blog_id` int(11) default NULL,
  `rss` varchar(500) NOT NULL,
  `title` varchar(2000) default NULL,
  `description` text,
  `link` varchar(500) default NULL,
  `language` varchar(20) default NULL,
  `icon_url` varchar(500) default NULL,
  `icon_title` varchar(2000) default NULL,
  `icon_link` varchar(500) default NULL,
  `score` int(11) default NULL,
  `folder_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `search_logs` (
  `id` int(11) NOT NULL auto_increment,
  `area` varchar(100) default NULL,
  `keyword` varchar(100) default NULL,
  `city_id` int(11) NOT NULL,
  `member_id` int(11) default NULL,
  `hot_spot_count` int(11) default NULL,
  `from_mobile` tinyint(1) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=381 DEFAULT CHARSET=utf8;

CREATE TABLE `taboo_words` (
  `id` int(11) NOT NULL auto_increment,
  `word` varchar(30) NOT NULL,
  `regexp` varchar(180) default NULL,
  `active` tinyint(1) default '1',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

CREATE TABLE `traffic_lines` (
  `id` int(11) NOT NULL auto_increment,
  `name_zh_cn` varchar(300) default NULL,
  `name_en` varchar(300) default NULL,
  `line_type` int(11) NOT NULL default '1',
  `introduction_zh_cn` varchar(3000) default NULL,
  `introduction_en` varchar(3000) default NULL,
  `city_id` int(11) default NULL,
  `fid` int(11) default NULL,
  `operation_time_zh_cn` varchar(600) default NULL,
  `operation_time_en` varchar(600) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3012 DEFAULT CHARSET=latin1;

CREATE TABLE `traffic_stops` (
  `id` int(11) NOT NULL auto_increment,
  `traffic_line_id` int(11) NOT NULL,
  `position` int(11) NOT NULL default '0',
  `hot_spot_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23227 DEFAULT CHARSET=latin1;

CREATE TABLE `votes` (
  `id` int(11) NOT NULL auto_increment,
  `member_id` int(11) NOT NULL,
  `target_type` varchar(30) NOT NULL,
  `target_id` int(11) NOT NULL,
  `vote` int(11) default NULL,
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=utf8;

CREATE TABLE `zoom_levels` (
  `id` int(11) NOT NULL auto_increment,
  `layout_map_id` int(11) NOT NULL,
  `width` int(11) default NULL,
  `height` int(11) default NULL,
  `scale` int(11) NOT NULL default '1',
  `map_file` varchar(255) default NULL,
  `map_file_width` int(11) default NULL,
  `map_file_height` int(11) default NULL,
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('10');

INSERT INTO schema_migrations (version) VALUES ('11');

INSERT INTO schema_migrations (version) VALUES ('12');

INSERT INTO schema_migrations (version) VALUES ('13');

INSERT INTO schema_migrations (version) VALUES ('16');

INSERT INTO schema_migrations (version) VALUES ('17');

INSERT INTO schema_migrations (version) VALUES ('18');

INSERT INTO schema_migrations (version) VALUES ('19');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('20');

INSERT INTO schema_migrations (version) VALUES ('20081124064245');

INSERT INTO schema_migrations (version) VALUES ('20081129032430');

INSERT INTO schema_migrations (version) VALUES ('20081208054614');

INSERT INTO schema_migrations (version) VALUES ('20081208061042');

INSERT INTO schema_migrations (version) VALUES ('20081208061618');

INSERT INTO schema_migrations (version) VALUES ('20081208062605');

INSERT INTO schema_migrations (version) VALUES ('20081213074848');

INSERT INTO schema_migrations (version) VALUES ('20081213075909');

INSERT INTO schema_migrations (version) VALUES ('20081215023302');

INSERT INTO schema_migrations (version) VALUES ('20081215121126');

INSERT INTO schema_migrations (version) VALUES ('20081217024538');

INSERT INTO schema_migrations (version) VALUES ('20081219022341');

INSERT INTO schema_migrations (version) VALUES ('20081225012712');

INSERT INTO schema_migrations (version) VALUES ('20090104062927');

INSERT INTO schema_migrations (version) VALUES ('20090104063152');

INSERT INTO schema_migrations (version) VALUES ('20090113083741');

INSERT INTO schema_migrations (version) VALUES ('20090114021457');

INSERT INTO schema_migrations (version) VALUES ('20090114082928');

INSERT INTO schema_migrations (version) VALUES ('20090122062643');

INSERT INTO schema_migrations (version) VALUES ('20090201054018');

INSERT INTO schema_migrations (version) VALUES ('20090202025043');

INSERT INTO schema_migrations (version) VALUES ('20090203022818');

INSERT INTO schema_migrations (version) VALUES ('20090203033740');

INSERT INTO schema_migrations (version) VALUES ('20090203054223');

INSERT INTO schema_migrations (version) VALUES ('20090204054319');

INSERT INTO schema_migrations (version) VALUES ('20090204072752');

INSERT INTO schema_migrations (version) VALUES ('20090206015227');

INSERT INTO schema_migrations (version) VALUES ('20090206061325');

INSERT INTO schema_migrations (version) VALUES ('20090218041057');

INSERT INTO schema_migrations (version) VALUES ('20090218042719');

INSERT INTO schema_migrations (version) VALUES ('20090218072100');

INSERT INTO schema_migrations (version) VALUES ('20090227072553');

INSERT INTO schema_migrations (version) VALUES ('20090304013443');

INSERT INTO schema_migrations (version) VALUES ('20090304013512');

INSERT INTO schema_migrations (version) VALUES ('20090304013550');

INSERT INTO schema_migrations (version) VALUES ('20090304083808');

INSERT INTO schema_migrations (version) VALUES ('20090305020355');

INSERT INTO schema_migrations (version) VALUES ('20090320033202');

INSERT INTO schema_migrations (version) VALUES ('20090325022950');

INSERT INTO schema_migrations (version) VALUES ('20090327015643');

INSERT INTO schema_migrations (version) VALUES ('21');

INSERT INTO schema_migrations (version) VALUES ('22');

INSERT INTO schema_migrations (version) VALUES ('24');

INSERT INTO schema_migrations (version) VALUES ('25');

INSERT INTO schema_migrations (version) VALUES ('26');

INSERT INTO schema_migrations (version) VALUES ('27');

INSERT INTO schema_migrations (version) VALUES ('28');

INSERT INTO schema_migrations (version) VALUES ('29');

INSERT INTO schema_migrations (version) VALUES ('3');

INSERT INTO schema_migrations (version) VALUES ('30');

INSERT INTO schema_migrations (version) VALUES ('31');

INSERT INTO schema_migrations (version) VALUES ('32');

INSERT INTO schema_migrations (version) VALUES ('33');

INSERT INTO schema_migrations (version) VALUES ('34');

INSERT INTO schema_migrations (version) VALUES ('35');

INSERT INTO schema_migrations (version) VALUES ('36');

INSERT INTO schema_migrations (version) VALUES ('37');

INSERT INTO schema_migrations (version) VALUES ('38');

INSERT INTO schema_migrations (version) VALUES ('39');

INSERT INTO schema_migrations (version) VALUES ('4');

INSERT INTO schema_migrations (version) VALUES ('40');

INSERT INTO schema_migrations (version) VALUES ('41');

INSERT INTO schema_migrations (version) VALUES ('42');

INSERT INTO schema_migrations (version) VALUES ('43');

INSERT INTO schema_migrations (version) VALUES ('44');

INSERT INTO schema_migrations (version) VALUES ('45');

INSERT INTO schema_migrations (version) VALUES ('46');

INSERT INTO schema_migrations (version) VALUES ('47');

INSERT INTO schema_migrations (version) VALUES ('48');

INSERT INTO schema_migrations (version) VALUES ('49');

INSERT INTO schema_migrations (version) VALUES ('5');

INSERT INTO schema_migrations (version) VALUES ('50');

INSERT INTO schema_migrations (version) VALUES ('51');

INSERT INTO schema_migrations (version) VALUES ('52');

INSERT INTO schema_migrations (version) VALUES ('53');

INSERT INTO schema_migrations (version) VALUES ('54');

INSERT INTO schema_migrations (version) VALUES ('55');

INSERT INTO schema_migrations (version) VALUES ('56');

INSERT INTO schema_migrations (version) VALUES ('57');

INSERT INTO schema_migrations (version) VALUES ('58');

INSERT INTO schema_migrations (version) VALUES ('59');

INSERT INTO schema_migrations (version) VALUES ('6');

INSERT INTO schema_migrations (version) VALUES ('60');

INSERT INTO schema_migrations (version) VALUES ('61');

INSERT INTO schema_migrations (version) VALUES ('62');

INSERT INTO schema_migrations (version) VALUES ('63');

INSERT INTO schema_migrations (version) VALUES ('64');

INSERT INTO schema_migrations (version) VALUES ('65');

INSERT INTO schema_migrations (version) VALUES ('66');

INSERT INTO schema_migrations (version) VALUES ('67');

INSERT INTO schema_migrations (version) VALUES ('68');

INSERT INTO schema_migrations (version) VALUES ('69');

INSERT INTO schema_migrations (version) VALUES ('70');

INSERT INTO schema_migrations (version) VALUES ('71');

INSERT INTO schema_migrations (version) VALUES ('72');

INSERT INTO schema_migrations (version) VALUES ('73');

INSERT INTO schema_migrations (version) VALUES ('74');

INSERT INTO schema_migrations (version) VALUES ('75');

INSERT INTO schema_migrations (version) VALUES ('76');

INSERT INTO schema_migrations (version) VALUES ('77');

INSERT INTO schema_migrations (version) VALUES ('78');

INSERT INTO schema_migrations (version) VALUES ('79');

INSERT INTO schema_migrations (version) VALUES ('8');

INSERT INTO schema_migrations (version) VALUES ('80');

INSERT INTO schema_migrations (version) VALUES ('81');

INSERT INTO schema_migrations (version) VALUES ('82');

INSERT INTO schema_migrations (version) VALUES ('83');

INSERT INTO schema_migrations (version) VALUES ('84');

INSERT INTO schema_migrations (version) VALUES ('85');

INSERT INTO schema_migrations (version) VALUES ('86');

INSERT INTO schema_migrations (version) VALUES ('87');

INSERT INTO schema_migrations (version) VALUES ('88');

INSERT INTO schema_migrations (version) VALUES ('89');

INSERT INTO schema_migrations (version) VALUES ('9');

INSERT INTO schema_migrations (version) VALUES ('90');

INSERT INTO schema_migrations (version) VALUES ('91');