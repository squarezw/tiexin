                       

var HotSpotMarker=Class.create();                         

HotSpotMarker.markers={};

Object.extend(HotSpotMarker.prototype, {
   initialize: function (map, point, id, opts) {
   		this.id = id;
		if (opts.icon != null) {
			opts.icon = HotSpotMarker.create_icon(opts.icon);
		}
		this.marker = new GMarker (point, opts);
		this.marker.model = this;     
		map.addOverlay(this.marker); 
		GEvent.addListener(this.marker, 'click', HotSpotMarker.show_infor);  
		if (opts && opts.draggable)
			this.registe_listener_for_dnd();
		HotSpotMarker.markers[id] = this;
	},
	
	registe_listener_for_dnd: function () {
		GEvent.addListener(this.marker, 'dragstart', this.on_drag_start);  
		GEvent.addListener(this.marker, 'dragend', this.on_drag_end);
	},
	
	on_drag_start : function () {
		map.closeInfoWindow();
	},
	
	on_drag_end : function () {
		if (! Ajax.Request) {
			alert ("I need Ajax.Request!");
			return;
		}                                     
		var new_point = this.getPoint();
		new Ajax.Request(
			'/hot_spots/' + this.model.id + ';move',
			{
				method : 'post',
				parameters: { latitude : new_point.lat(),
							  longitude : new_point.lng() }
			}
		);
	}
});                                                                      

HotSpotMarker.show_infor = function () {
	new Ajax.Request(
		'/hot_spots/' + this.model.id + '.js;show_marker_info',
		{ method: 'get' });
}                                       

HotSpotMarker.show_infor_window = function(id, content) {
	var marker = HotSpotMarker.markers[id];
	if (marker) 
		marker.marker.openInfoWindowHtml(content);
}                              

HotSpotMarker.goto_hotspot = function (id) {
	var marker = HotSpotMarker.markers[id];
	map.setCenter(marker.marker.getPoint(), 16);
}

HotSpotMarker.create = function (map, point, id, options) {
	var marker = HotSpotMarker.markers[id];
	if ( marker != null)
		return marker;
	return new HotSpotMarker (map, point, id, options);
}

HotSpotMarker.create_icon = function (image) {
	var icon = new GIcon ();
	icon.image = image;
	icon.iconSize = new GSize (19,19);
	icon.iconAnchor = new GPoint (10,10);
	icon.infoWindowAnchor = new GPoint (10, 0);
	return icon;
}

var AreaMarker=Class.create();

AreaMarker.markers = {};

Object.extend (AreaMarker.prototype, {
	initialize: function (map, nw_point, se_point, id) {
		this.id = id;
		this.marker = new GMarker (new GLatLngBounds(nw_point, se_point).getCenter());
		this.marker.model = this;
		map.addOverlay (this.marker);
		GEvent.addListener(this.marker, 'click', AreaMarker.show_infor);
		AreaMarker.markers[id] = this;
	}
});                                   

AreaMarker.show_infor = function () {
	new Ajax.Request(
		'/admin/areas/' + this.model.id + '.js;show_marker_info',
		{ method: 'get' });
}    

AreaMarker.show_infor_window = function(id, content) {
	var marker = AreaMarker.markers[id];
	if (marker) 
		marker.marker.openInfoWindowHtml(content);
}

function new_map_set_marker(id, latitude, longitude) {
	if ( ! MapSet.find_marker(id)) {      
		MapSet.markers[id]=new MapSet(map, id, latitude, longitude); 
	}
}                                                      

function show_infor_window(latitude, longitude, content_html) {
	map.openInfoWindowHtml(new GLatLng(latitude, longitude), content_html);
}        


