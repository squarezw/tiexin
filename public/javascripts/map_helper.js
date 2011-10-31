function add_hot_spot_to_map (x, y, options) {
	var marker = map.get_marker_by_property_value('hot_spot_id', options.hot_spot_id);
	if (marker)
		return;
	new HotSpotMarker (map, x, y, options);
}

function show_hot_spot_marker (id, with_bubble) {
	if (with_bubble == undefined) {
		with_bubble = 1;
	}
	var marker = map.get_marker_by_property_value('hot_spot_id', id);
	if (marker) {
		map.set_position(marker.x, marker.y);
		if (marker.options.bubble_content != '')
			map.show_bubble(marker.x, marker.y, marker.options.bubble_content);
	} else {
		new Ajax.Request('/hot_spots/' + id + '/marker', 
						 { method: 'get',
						   parameters: { bubble: with_bubble }}
						);
	}
}

function register_listener_to_show_bubble(map) {
	map.add_event_listener('click_marker', function(event) {
		map.set_position(this.x, this.y);
		if (this.show_info_bubble)
			this.show_info_bubble ();
	});
}