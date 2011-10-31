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
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

CREATE TABLE `articles` (
  `id` int(11) NOT NULL auto_increment,
  `subject` varchar(3000) NOT NULL,
  `member_id` int(11) NOT NULL,
  `folder_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `read_times` int(11) NOT NULL default '0',
  `comments_count` int(11) default '0',
  `hot_spot_id` int(11) default NULL,
  `brand_id` int(11) default NULL,
  `content` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `blogs` (
  `id` int(11) NOT NULL auto_increment,
  `member_id` int(11) NOT NULL,
  `created_at` datetime default NULL,
  `articles_count` int(11) NOT NULL default '0',
  `name` varchar(90) NOT NULL,
  `simple_name` varchar(50) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `bulletins` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(90) NOT NULL,
  `language` varchar(10) NOT NULL default 'zh_cn',
  `content` text,
  `expire_date` date default NULL,
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

CREATE TABLE `cities_promotions` (
  `city_id` int(11) NOT NULL,
  `promotion_id` int(11) NOT NULL
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
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `folders` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(90) NOT NULL,
  `member_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `hot_spot_access_logs` (
  `id` int(11) NOT NULL auto_increment,
  `member_id` int(11) default NULL,
  `hot_spot_id` int(11) NOT NULL,
  `created_at` datetime default NULL,
  `from_mobile` tinyint(1) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

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
  `phone_number` varchar(60) default NULL,
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
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

CREATE TABLE `layout_maps` (
  `id` int(11) NOT NULL auto_increment,
  `name_en` varchar(60) default NULL,
  `name_zh_cn` varchar(60) default NULL,
  `layoutable_type` varchar(255) NOT NULL,
  `layoutable_id` int(11) NOT NULL,
  `introduction_zh_cn` varchar(3000) default NULL,
  `introduction_en` varchar(3000) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `map_levels` (
  `id` int(11) NOT NULL auto_increment,
  `city_id` int(11) NOT NULL,
  `no` int(11) NOT NULL,
  `scale` float NOT NULL,
  `row` int(11) NOT NULL,
  `column` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=latin1;

CREATE TABLE `members` (
  `id` int(11) NOT NULL auto_increment,
  `login_name` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `mail` varchar(255) NOT NULL,
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
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

CREATE TABLE `navi_photos` (
  `id` int(11) NOT NULL auto_increment,
  `owner_type` varchar(255) NOT NULL,
  `owner_id` int(11) NOT NULL,
  `subject` varchar(300) default NULL,
  `photo` varchar(255) default NULL,
  `uploader_id` int(11) NOT NULL,
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `positions` (
  `id` int(11) NOT NULL auto_increment,
  `hot_spot_id` int(11) NOT NULL,
  `layout_map_id` int(11) NOT NULL,
  `x` float NOT NULL,
  `y` float NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `promotions` (
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
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `taboo_words` (
  `id` int(11) NOT NULL auto_increment,
  `word` varchar(30) NOT NULL,
  `regexp` varchar(180) default NULL,
  `active` tinyint(1) default '1',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `traffic_stops` (
  `id` int(11) NOT NULL auto_increment,
  `traffic_line_id` int(11) NOT NULL,
  `position` int(11) NOT NULL default '0',
  `hot_spot_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `votes` (
  `id` int(11) NOT NULL auto_increment,
  `member_id` int(11) NOT NULL,
  `target_type` varchar(30) NOT NULL,
  `target_id` int(11) NOT NULL,
  `vote` int(11) default NULL,
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO schema_info (version) VALUES (63)