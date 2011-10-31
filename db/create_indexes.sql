create index idx_hot_spot_tags_hot_spot_id_tag on hot_spot_tags(hot_spot_id, tag);
create index idx_hot_spot_tags_tag on hot_spot_tags(tag);
create index idx_hot_spot_brand_id on hot_spots(brand_id);
create index idx_photo_owner on navi_photos(owner_type, owner_id);
create index idx_event_vendor on events(vendor_type, vendor_id);
create index idx_hot_spot_owner_Id on hot_spots(owner_id);
create index idx_cities_events_event_id on cities_events(event_id);
create index idx_hot_spots_container on hot_spots(container_id);
create index idx_hot_spot_categories_traffic_stop_type on hot_spot_categories(traffic_stop_type);
	
	
	