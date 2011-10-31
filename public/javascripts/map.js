function event_from_bubble(event) {
	var node = event.srcElement ? event.srcElement : event.target;
	while (node) {
		if ('map_bubble_body' == node.id) {
			return true;
		}
		node = node.parentNode;
	}
	return false;
}

var TILE_WIDTH = 128;
var TILE_HEIGHT = 128;

var Map = Class.create();                            

Map.prototype = { 
	zoom_levels: [],
	
	initialize: function (div_id, options) {
		this.options = {
			tile_size: 128,
			viewport_width: 640,
			viewport_height: 480,
			city_id: 1
		};                       
		
		Object.extend (this.options, options || {});  
		
		var outer_div = $(div_id);          
		
		outer_div.style.width= this.options.viewport_width + 'px';
		outer_div.style.height= this.options.viewport_height + 'px';
		
		if ( /MSIE/.test(navigator.userAgent) && !window.opera) {
			document.onmouseup = this.stop_move.bind(this);
		} else {
			window.onmouseup = this.stop_move.bind(this);
		}

		outer_div.model = this;           
/*
		outer_div.onmousedown=this.start_move.bind(this);
		outer_div.onmousemove=this.process_move.bind(this);
		outer_div.onmouseup=this.stop_move.bind(this);               
		outer_div.onclick=this.on_click.bind(this);    
*/
		
		var event_layer = document.createElement('div');
		Element.Methods.setStyle(event_layer, {
			zIndex: 10,
			position: 'absolute',
			left: '0px',
			top: '0px',
			width: this.options.viewport_width,
			height: this.options.viewport_height
		});
		event_layer.onmousedown=this.start_move.bind(this);
		event_layer.onmousemove=this.process_move.bind(this);
		event_layer.onmouseup=this.stop_move.bind(this);               
		event_layer.onclick=this.on_click.bind(this);    
		
		if (event_layer.addEventListener) {
			event_layer.addEventListener('DOMMouseScroll', this.on_mouse_wheel.bind(this), false);
		} else if (event_layer.attachEvent){
			event_layer.attachEvent("onmousewheel", this.on_mouse_wheel.bind(this));
		}
		this.event_layer = event_layer;
		outer_div.appendChild (event_layer);
		
		/* Enable drag and drop in IE */		
		outer_div.ondragstart= function () {return false;}  
		this.outer_div = outer_div;
		
		this.inner_div = document.createElement('div');    
		this.inner_div.setAttribute('id', 'xnavi_inner');
		this.inner_div.style['zIndex']=10;
//		this.inner_div.setStyle({zIndex : 10});


        this.set_zoom_levels(this.options.zoom_levels);

		this.tile_layer = new XTileLayer(10, this.options);
		
		this.inner_div.appendChild(this.tile_layer.view);
		                                                      
		this.marker_layer = new XMarkerLayer (this, 20);
		this.inner_div.appendChild(this.marker_layer.view);
		
		this.bubble = new XBubble(30, this);
		this.inner_div.appendChild(this.bubble.view);
		
//		outer_div.appendChild (this.inner_div);  
		event_layer.appendChild (this.inner_div);
		this.container = outer_div;
		
		this.dragging = false;                                      
		this.top = 0;
		this.left = 0;   

		if (options.init_zoom_level_index) {
			this.set_current_zoom_level_index(options.init_zoom_level_index);
		}
		
		if (options.start_point) {
			this.set_position(options.start_point[0], options.start_point[1]);
		} else {
		  	this.check_tiles ();
		}
	},   
	
	resize: function (width, height) {
		this.outer_div.style.width = width + 'px';
		this.outer_div.style.height = height + 'px';
		this.event_layer.style.width = width + 'px';
		this.event_layer.style.height = height + 'px';
		this.options.viewport_width = width;
		this.options.viewport_height = height;
		this.check_tiles();
	},
	
	add_control: function (control) {
		this.outer_div.appendChild(control.view);
		control.set_zIndex (1000);
		if (control.is_slider && control.is_slider()) {
			this.slider = control;
		}
	},

	change_layout_map : function (layout_map) {  
		this.tile_layer.clear();
		this.set_zoom_levels(layout_map.zoom_levels);
		this.check_tiles();       
		this.goto_center();
	},       
	
	set_zoom_levels : function (zoom_levels) {
		this.zoom_levels = [];
		for (var i=0; i< zoom_levels.length; ++i) {
			this.zoom_levels[i] = new XZoomLevel(this, zoom_levels[i]);
		}                 
		this.set_current_zoom_level_index(0);
	},                                 
	
	on_mouse_wheel: function(event) {
		event = event ? event : window.event;
		if (event_from_bubble(event))
			return false;
		var wheel_data = event.detail ? (event.detail * -1) : (event.wheelDelta / 120);
		var zoom_delta = - wheel_data;
		var new_index = this.current_zoom_level_index - zoom_delta;
		new_index = Math.max(Math.min(new_index, this.zoom_levels.length - 1), 0);
		if (new_index != this.current_zoom_level_index) {
			this.zoom_to (new_index);
		}
		if (this.slider) {
			this.slider.set_zoom_level_index(new_index);
		}
		return false;
	},
	                                                           
	set_current_zoom_level_index : function (index) {  
		if (index >= this.zoom_levels.length) 
			index = this.zoom_levels.length - 1;
		if (index < 0)
			index = 0;                     
		this.current_zoom_level_index = index;
		var zoom_level_0 = this.zoom_levels[index];
		this.inner_div.style.width = zoom_level_0.map_width + "px";
		this.inner_div.style.height = zoom_level_0.map_height + "px"; 
		this.inner_div.style.position = 'relative';
		this.inner_div.style.left = '0px';
		this.inner_div.style.top = '0px';
		this.current_zoom_level=zoom_level_0;  
	},

	goto_center : function () {                                
		var center = this.current_zoom_level.center();
		this.inner_div.style.left = -(center[0] - this.options.viewport_width / 2) + "px";
		this.inner_div.style.top = -(center[1] - this.options.viewport_height / 2) + "px"; 
		this.check_tiles();
	},                           
	                                                 
	// (x, y) is in map coordination
	set_position : function (x, y) {      
	    var point = this.current_zoom_level.map_to_zoom_level(x, y);
		this.inner_div.style.left = (this.options.viewport_width / 2 - point[0]) + "px";
		this.inner_div.style.top = (this.options.viewport_height / 2 - point[1]) + "px"; 
		this.check_tiles();
	},
	
	start_move : function(event) {
		// necessary for IE
		if (! event) event=window.event;        
		
		if (event_from_bubble(event))
			return false;
		
		var m = this.find_marker_contains(event.clientX, event.clientY);
		if (this.can_move_marker && m && m.movable) {
			this.moving_marker = m;                                  
			var pos = m.position();
			this.top = pos[1];
			this.left = pos[0];
		} else {
			this.top = stripPx(this.inner_div.style.top);
			this.left = stripPx(this.inner_div.style.left);  
		}
		this.drag_start_x = event.clientX;
		this.drag_start_y = event.clientY;
/*
		if ( /Mozilla/.test(navigator.userAgent) && !window.opera) {
			this.inner_div.style.cursor = "-moz-grab";        
		}
*/
		this.dragging= true;
		return false;		
	},           
	
	in_bubble : function (clientX, clientY) {
		var p = Position.page(this.container);
		var x_offset = clientX - p[0];
		var y_offset = clientY - p[1];
		var container_offset = Position.cumulativeOffset(this.container);
		return this.bubble.visible && this.bubble.contains (x_offset + container_offset[0], y_offset + container_offset[1]);
	},
	
	find_marker_contains: function(clientX, clientY) {              
		var p = Position.page(this.container);
		var x_offset = clientX - p[0];
		var y_offset = clientY - p[1];
		var container_offset = Position.cumulativeOffset(this.container);
		var marker = this.marker_layer.find_marker_contains(x_offset + container_offset[0], y_offset + container_offset[1]);
		return marker;
	},
	
	process_move : function(event) {
		if (!event) event=window.event;          
		if (! this.dragging) 
			return true;
			
		var new_top= this.top + (event.clientY - this.drag_start_y);      
		var new_left = this.left + (event.clientX - this.drag_start_x);

		if (this.moving_marker) {
			this.process_move_marker(new_left, new_top);
		} else {                                                                 
			this.process_move_map (new_left , new_top);
		}		
	},                   
	
	move: function (delta_x, delta_y) {
		this.process_move_map (stripPx(this.inner_div.style.left) + delta_x,
							   stripPx(this.inner_div.style.top) + delta_y);
	},
	
	process_move_map : function(new_left, new_top) {
		this.inner_div.style.top= new_top + 'px';
		this.inner_div.style.left= new_left + 'px';
		this.check_tiles (); 
	},              
	
	process_move_marker : function(new_left, new_top) {              
		this.moving_marker.set_position(new_left, new_top);
	},
	                                                                      
	stop_move : function(event) {                                         
		if (this.moving_marker) {                                              
			var new_pos = this.moving_marker.position();
			if (new_pos[1] != this.top ||
			    new_pos[0] != this.left) {   
				var new_coordinate = this.current_zoom_level.zoom_level_to_map(new_pos[0], new_pos[1]);
				this.moving_marker.move_to(new_coordinate[0], new_coordinate[1]);
				this.fire_event(this.moving_marker, 
								new XEvent('marker_moved', new_coordinate[0], new_coordinate[1]));
			}
		}
		
		this.inner_div.style.cursor='';
		this.dragging = false;		        
		this.moving_marker = null;
		this.marker_to_be_moved = null;                   
		
	},
	
	
	check_tiles : function  () {
		this.tile_layer.check_tiles(this.get_visible_tiles(), this.current_zoom_level);
	},
	
	get_visible_tiles : function  () {     
		var startX = Math.abs(Math.floor(this.map_left() / this.options.tile_size)) - 1;
		var startY = Math.abs(Math.floor(this.map_top() / this.options.tile_size)) - 1;  
		
		var tilesX = Math.ceil(this.options.viewport_width / this.options.tile_size) + 1; 
		var tilesY = Math.ceil(this.options.viewport_height / this.options.tile_size) + 1;    

		                                                
		var visibleTileArray = [];
		var counter = 0;                           
		var endX = Math.min(tilesX + startX, this.current_zoom_level.tile_columns);
		var endY = Math.min(tilesY + startY, this.current_zoom_level.tile_rows);
		window.status = "(" + startX + "," + startY + ") to (" + endX + "," + endY + ")";
		for (x=startX; x < endX; x++) {
			for (y = startY; y< endY; y++) {                                                                         
				
				if (x >=0 && y >= 0 )
					visibleTileArray[counter++] = [x,y];
			}
		}  
		return visibleTileArray;
	},             
	
	map_left: function () {
		return stripPx(this.inner_div.style.left);
	},
	
	map_top: function() {
		return stripPx(this.inner_div.style.top);
	},
	                                         
	// (x, y) is in map coordination.
	add_marker: function (marker) {
		return this.marker_layer.add_marker(marker);
	},
	
	remove_marker: function (marker) {
		this.marker_layer.remove_marker(marker);
	},
	
	on_click: function(event) { 
		if (! event)  event = window.event;
		
		if (event.clientX != this.drag_start_x ||
			event.clientY != this.drag_start_y)
			return;                
		var point = this.client_to_map([event.clientX, event.clientY]); 
		this.fire_event(this, new XEvent('click', point[0], point[1]));
	},
	
	client_to_map: function (client_point) {
		var p = this.client_to_zoom_level (client_point);  
		return this.current_zoom_level.zoom_level_to_map(p[0], p[1]);
	},                              
	
	client_to_zoom_level: function(client_point) {
		var p = Position.page(this.container);
		return this.viewport_to_zoom_level([client_point[0] - p[0], client_point[1] - p[1]]);
	},
	
	is_in_map : function (x,y) {
		return x >=0 &&
			   x < this.current_zoom_level.map_width &&
			   y >=0 &&
			   y < this.current_zoom_level.map_height;
	},           
	
	is_client_in_map: function (client_point) {
		var p = this.client_to_zoom_level(client_point);
		return is_in_map(p[0], p[1]);
	},
	
	viewport_to_zoom_level: function (pixel) {    
		return  [ pixel[0] - this.map_left(),
				  pixel[1] - this.map_top()  ];
	},
	
	add_event_listener: function (event, handler) {
		this.get_listeners(event).push(handler);
	},                                       
	
	get_listeners: function (event) {     
		if (! this.listeners) {
			this.listeners = {};
		}
		var listeners = this.listeners[event];
		if (! listeners) {
			listeners = new Array();
			this.listeners[event] = listeners;
		}                 
		return listeners;
	},
	
	fire_event: function(target, event) {                
		var listeners = this.get_listeners(event.event_type);
		if (! listeners)
			return;
		for (i=0; i<listeners.length; ++i) {
			listeners[i].apply(target, [event]);
		}
	}, 
	
	set_marker_visible_by_property_value: function (property_name, property_value, visible) {
		this.marker_layer.set_marker_visible_by_property_value(property_name, property_value, visible);
	},
	
	get_marker_by_property_value: function(property_name, property_value) {
		return this.marker_layer.get_marker_by_property_value(property_name, property_value);
	},
	
	clear_markers : function () {
		this.marker_layer.clear();
	},
	
	set_zoom_level: function(level) {
		var old_status = this.preserve_status ();
		this.set_current_zoom_level_index(level);
		if (old_status.zoom_level_index != this.current_zoom_level_index) {
			this.restore_position(old_status);
            this.after_zoom(old_status);
		}		
	},
	
	zoom_out : function () {
		var old_status = this.preserve_status ();
		this.set_current_zoom_level_index(this.current_zoom_level_index - 1);
		this.restore_position(old_status);
		if (old_status.zoom_level_index != this.current_zoom_level_index) {
            this.after_zoom(old_status);
		}
	},

	zoom_in : function () {
		var old_status = this.preserve_status ();
		this.set_current_zoom_level_index(this.current_zoom_level_index + 1);
		this.restore_position(old_status);
		if (old_status.zoom_level_index != this.current_zoom_level_index) {
			this.after_zoom(old_status);
		}
	},         
	
	zoom_to : function (index) {
		var old_status = this.preserve_status ();
		this.set_current_zoom_level_index(index);
		this.restore_position(old_status);
		if (old_status.zoom_level_index != this.current_zoom_level_index) {
			this.after_zoom(old_status);
		}
		if (this.slider) {
			this.slider.set_zoom_level_index(index);
		}
		
	},
	
	preserve_status: function () {
		return {
			zoom_level_index : this.current_zoom_level_index,
			center: this.current_zoom_level.zoom_level_to_map (
				this.options.viewport_width / 2 - this.map_left() ,
				this.options.viewport_height / 2 - this.map_top() )
		};
	},
	
	get_position: function() {
		return this.current_zoom_level.zoom_level_to_map (
			this.options.viewport_width / 2 - this.map_left() ,
			this.options.viewport_height / 2 - this.map_top() );
	},
	
	after_zoom: function (old_status) {
		this.tile_layer.clear();
		this.check_tiles();                  
		this.marker_layer.zoom_level_changed(this.current_zoom_level);                       
	},
	
	restore_position: function(old_status) {
		this.set_position(old_status.center[0], old_status.center[1]);
		this.bubble.zoom_level_changed(this.current_zoom_level);
	},
	
	enable_move_marker : function () {
		this.can_move_marker = true;
	},

	move_marker_to : function (position_id, x, y) {
	 	var marker = this.marker_layer.get_marker_by_property_value('position_id', position_id);
		if (marker) {
			marker.x = x;
			marker.y = y;
		}
	},
	
	show_bubble: function (x, y, html) {
		var pos = this.current_zoom_level.map_to_zoom_level(x, y);
		this.bubble.show(pos[0], pos[1], html);
	},
	
	move_bubble_to: function (x, y) {
		var pos = this.current_zoom_level.map_to_zoom_level(x, y);
		this.bubble.move_to(pos[0], pos[1]);
	},
	
	hide_bubble: function () {
		this.bubble.hide();
	},
	
	set_cursor: function(cursor) {
		Element.Methods.setStyle(this.inner_div, {cursor: cursor});
	},
	
	clear_markers: function () {
		this.marker_layer.clear ();
	}
}   

var XTileLayer = Class.create ();

XTileLayer.prototype = {
	initialize: function (z_index, options) {
		this.view = document.createElement('div');
		this.z_index = z_index;
		Element.setStyle(this.view, {
			position: 'absolute',
			left: '0px',
			top: '0px',
			zIndex: z_index || 10
		});                               
		
		this.options= {};
		Object.extend (this.options, options || {});
	},
	
	check_tiles : function  (visibleTiles, zoom_level) {
		var visibleTilesMap = {};                     
		var path = "/map_blocks/" + this.options.city_id + "/" + zoom_level.no + "/" ;
		for (i=0; i < visibleTiles.length; i++) {      
			var tileArray = visibleTiles[i];
			var tileName = build_map_block_url(this.options.city_id, zoom_level.no, tileArray[0], tileArray[1]);
//			var tileName=tileArray[0] + "/" + tileArray[1];
			visibleTilesMap[tileName] = true;
			var img=$(tileName);
			if (! img) {
				img = document.createElement("img");
//				img.src= path + tileName;
				img.src = tileName;
				img.style.position="absolute";
				img.style.left = (tileArray[0] * this.options.tile_size) + "px";
				img.style.top = (tileArray[1] * this.options.tile_size) + "px";
				img.style.zIndex = this.z_index + 1;
				img.setAttribute("id", tileName);
				this.view.appendChild(img);
			}
		}   
		
		var imgs= this.view.getElementsByTagName("img");
		for (i=0; i< imgs.length; ++i) {
			var id=imgs[i].getAttribute("id");
			if (! visibleTilesMap[id]) {
				this.view.removeChild(imgs[i]);
				i--;
			}
		}
	},
	
	clear :function () {
		var nodes = this.view.getElementsByTagName('img');
		for (var i=nodes.length - 1; i>=0; --i) {
//			nodes[i].remove();
			Element.Methods.remove (nodes[i]);
		}
	}
}

function build_map_block_url(city_id, zoom_level_no, x, y) {
	var url = "/images/map_blocks/" + city_id + "/" + zoom_level_no + "/" + Math.floor(y/10) + "/" + Math.floor(x/10) + "/";
	x = '00000000' + x;
	x = x.substr(x.length - 8);
	y = '00000000' + y;
	y = y.substr(y.length - 8);
	return url + y + "_" + x + ".png";
}

var XMarkerLayer = Class.create();

XMarkerLayer.prototype = { 
	markers : [],
	
	initialize: function(xnavi_map, z_index, options) {  
		this.map = xnavi_map;
		this.view = document.createElement('div');
		Element.setStyle(this.view, {
			position: 'absolute',
			left: '0px',
			right: '0px',
			zIndex: z_index || 20
		});
	},
	
	add_marker: function (marker) {
		this.view.appendChild(marker.element);    
//		this.markers.push(marker);
		this.markers[this.markers.length] = marker;
		return marker;
	},
	
	remove_marker: function (marker) {
		for (var i=0; i<this.markers.length; ++i) {
			if (this.markers[i] != null && this.markers[i] == marker)
				this.markers[i] = null;
		}
		this.markers = this.markers.compact ();
		marker.dispose();
	},
	
	get_marker_by_property_value: function(property_name, property_value) {
//		alert ("get_marker by " + property_name + " = " + property_value);
		for (var i=0; i<this.markers.length; ++i) {
//			alert ("this.markers[" + i + "].options[" + property_name + "] = " + this.markers[i].options[property_name]);
			if (this.markers[i].options[property_name] == property_value) { 
				return this.markers[i];
			}
		}
	},
	
	set_marker_visible_by_property_value: function (property_name, property_value, visible) { 
		for (var i=0; i<this.markers.length; ++i) {
			if (this.markers[i].options[property_name] == property_value) { 
				this.markers[i].set_visible(visible);
			}
		}
	},
	
	clear : function () {
		this.markers.each(function (marker) {
			marker.dispose ();
		});                  
		this.markers = [];
	},
	
	zoom_level_changed: function (new_zoom_level) {
		for (var i=0; i< this.markers.length; ++i) {
			this.markers[i].zoom_level_changed(new_zoom_level);
		}
	},
	
	find_marker_contains : function (x, y) {
		for (var i=0; i<this.markers.length; ++i) {
			var marker = this.markers[i];
			if (Position.within(this.markers[i].element, x, y))
				return this.markers[i];
		}   
		return null;
	}
}           

var XMarker = Class.create();

Object.extend(XMarker.prototype, {
	super_init: function (map, x, y, options) {
		this.set_options(options);
		this.map = map;                 
		this.x = x;
		this.y = y;
	},    

	set_options : function (options) {
		this.options = Object.extend({}, this.default_options);
		this.options = Object.extend(this.options, options || {});    		
	},
	
	create_view_element: function (element_name, event_listeners) {
		this.element = document.createElement(element_name);  
		this.element.id = this.options.unique_id;
		this.element.model = this;

		var point = this.map.current_zoom_level.map_to_zoom_level(this.x, this.y);				
		Element.setStyle(this.element, {
			position: 'absolute',
			width: this.options.width + 'px',
			height: this.options.height + 'px',
			zIndex: 50
		});         

		this.set_position(point[0], point[1]);
		
		if (this.options.tooltip) {
			this.set_tooltip(this.options.tooltip);
		}                                    
		
		Object.extend(this.element, event_listeners);
	},
	
	// (x, y) is in zoom_level coordination
	set_position : function (x, y) {
		Element.setStyle(this.element, {
			left : (x - this.options.anchor_point[0]) + 'px',
			top: (y - this.options.anchor_point[1]) + 'px'
		});
	},
	
	set_visible: function(visible) {
		if (visible)
			Element.show(this.element);
		else
			Element.hide(this.element);
	},
	
	set_tooltip: function(tooltip) {
		this.tool_tip = new YAHOO.widget.Tooltip ('tooltip_' + this.options.unique_id,
			{ context: this.element.id,
			  text: tooltip,
			  zIndex: 51 });
	},
	
	set_icon: function(icon) {
		this.element.src = icon;
			
	},
	
	dispose : function () {
		this.element.remove ();
		if (this.tool_tip)
			this.tool_tip.destroy ();
	},
	
	zoom_level_changed: function(new_zoom_level) {
		var point = new_zoom_level.map_to_zoom_level(this.x, this.y);
		this.set_position(point[0], point[1]);
	},
	
	position: function () {
		return [ stripPx(this.element.style.left) + this.options.anchor_point[0],
		         stripPx(this.element.style.top) + this.options.anchor_point[1] ];
	},
	
	// x, y is in XNavi coordinate
	move_to: function (x, y) {
		var point = this.map.current_zoom_level.map_to_zoom_level(x, y);
		this.set_position(point[0], point[1]);
		this.x = x;
		this.y = y;
	},
	
	default_on_click: function (event) {
		if (!event) event=window.event;
		this.map.fire_event(this, new XEvent('click_marker', 0, 0));    
		return false;
	},
	
	show_info_bubble: function () {
		if (this.options.bubble_content)
			this.map.show_bubble(this.x, this.y, this.options.bubble_content);		
	}
});                           

var HotSpotMarker = Class.create();

Object.extend(Object.extend(HotSpotMarker.prototype, XMarker.prototype), {
	movable : true,
	
	default_options: {
		icon: '/images/default_category.gif',
		width: 25,
		height: 33,
		anchor_point: [0, 32]
	},
	
	initialize: function (map, x, y, options) {
		this.super_init(map, x, y, options);
		this.create_view_element ('img', { onclick: this.default_on_click.bind(this) });
		this.element.src = this.options.icon;
		map.add_marker (this);
	}
});

var AreaMarker = Class.create();

Object.extend(Object.extend(AreaMarker.prototype, XMarker.prototype), {
	movable: false, 
	default_options: {
		icon: '/images/area1.gif',
		width: 24,
		height: 24,
		anchor_point: [12,12]
	},
	
	initialize: function (map, x, y, options) {
		this.super_init(map, x, y, options);
		this.create_view_element ('img', { onclick: this.default_on_click.bind(this),
			 							   onmousemove: this.on_mouse_over.bind(this)
										 } );
		this.element.src = this.options.icon;
		map.add_marker (this);
	},
	
	on_mouse_over: function(event) {
		if (this.scope_box)
			return;
		else
			this.show_scope_box();
	},
	
	show_scope_box: function() {
		this.scope_box = document.createElement('div');
		center_point = this.map.current_zoom_level.map_to_zoom_level(this.x, this.y);
		wh = this.map.current_zoom_level.map_to_zoom_level(this.options.area_width, this.options.area_height);
		Element.Methods.setStyle (this.scope_box, {
			left: (center_point[0] - wh[0] / 2) + 'px',
			top: (center_point[1] - wh[1] / 2) + 'px',
			width: wh[0] + 'px',
			height: wh[1] + 'px',
			position: 'absolute',
			border: '2px dashed red',
			zIndex: 49
		});
		this.map.marker_layer.view.appendChild(this.scope_box);
		setTimeout(this.remove_scope_box.bind(this), 2000);
	},
	
	remove_scope_box: function () {
		if (this.scope_box) {
			this.scope_box.remove ();
			this.scope_box = null;
		}
	},
	
	repositioned: function (x, y, width, height) {
		this.x = x; 
		this.y = y;
		this.options.area_width = width;
		this.options.area_height = height;
		this.move_to(x,y);
	}
});

var XEvent = Class.create();

XEvent.prototype = {
	source: null,
	
	initialize: function(event_type, map_x, map_y) {
		this.event_type = event_type;
		this.map_x = map_x;
		this.map_y = map_y;
	},  
	
	inspect: function () {
		return this.event_type + " at (" + this.map_x + "," + this.map_y + ")";
	}
}

var XZoomLevel = Class.create();  

Object.extend(XZoomLevel.prototype, {
	initialize: function (map, options) {
		Object.extend(this, options);
		this.map_width = this.tile_columns * TILE_WIDTH;
		this.map_height = this.tile_rows * TILE_HEIGHT;
		this.map = map;
	},
	                                             
	// Return coordination of center point, in zoom level's coordination system.
	center : function () {
		return [this.map_width / 2, this.map_height / 2];
	},
	                                                                            
	// Convert map coordination to zoom_level coordination.
	map_to_zoom_level: function (x, y) {
		return [ x / this.map.options.map_width * this.map_width, y / this.map.options.map_height * this.map_height];
	},
	
	// Convert zoom level coordination to map coordination
	zoom_level_to_map: function (x, y) {
		return [Math.round(x / this.map_width * this.map.options.map_width), Math.round(y / this.map_height * this.map.options.map_height)];
	}
});

var XBubble = Class.create();

var BUBBLE_HEIGHT = 246;
var BUBBLE_WIDTH = 400; // original 244
var BUBBLE_BOX_HEIGHT = 150;
var BUBBLE_BODY_HEIGHT = 140;

Object.extend(XBubble.prototype, {
	visible: false,
	
	initialize: function (z_index, map) {
		this.map = map;
		this.z_index = z_index;
		this.create_view();
 		Element.hide(this.view);
	},
	
	contains : function (x, y) {
		Position.within (this.view, x, y);
	},
	
	create_view: function () {
		this.view = document.createElement('div');
		Element.Methods.setStyle(this.view, 
			{ position: 'absolute',
			  zIndex: this.z_index,
			  backgroundColor: 'transparent' });


		this.view.appendChild(this.create_corner(0,0,25,25,0,0)); // top left corner
		this.view.appendChild(this.create_corner(0,BUBBLE_BOX_HEIGHT, 25, 25, 0, -665)); // bottom left corner
		this.view.appendChild(this.create_corner(BUBBLE_WIDTH,BUBBLE_BOX_HEIGHT, 25, 25, -665, -665)); // bottom right corner
		this.view.appendChild(this.create_corner(BUBBLE_WIDTH,0, 25, 25, -665, -0)); // top right corner
		this.view.appendChild(this.create_corner((BUBBLE_WIDTH - 98) / 2, BUBBLE_BOX_HEIGHT, 96, 98, 0, -690)); // arrow, 76


		var top = this.create_border(25, 0, 24, BUBBLE_WIDTH - 25);
		top.style['borderTopWidth'] = '1px';
		this.view.appendChild(top);

		var bottom = this.create_border(25, BUBBLE_BOX_HEIGHT, 24, BUBBLE_WIDTH - 25);
		bottom.style['borderBottomWidth'] = '1px';
		this.view.appendChild(bottom);
		
		var left = this.create_border(0, 25, BUBBLE_BOX_HEIGHT - 25, 24);
		left.style['borderLeftWidth'] = '1px';
		this.view.appendChild(left);
		
		var right = this.create_border(BUBBLE_WIDTH, 25, BUBBLE_BOX_HEIGHT - 25, 24);
		right.style['borderRightWidth'] = '1px';
		this.view.appendChild(right);
		
/*		
		var middle = document.createElement('div');
		Element.Methods.setStyle(middle, {
			position: 'absolute',
			left: '0px',
			top: '25px',
			width: '247px',
			height: '85px',
			backgroundColor: 'white',
			borderWidth: '0 1px 0 1px',
			borderStyle: 'solid',
			borderColor: '#ABABAB',
			zIndex: this.z_index
		});
		this.view.appendChild(middle);
*/
		
		var close_button = document.createElement('img');
		close_button.src='/images/iw_close.gif';
		Element.Methods.setStyle (close_button,  {
			position: 'absolute',
			left: (BUBBLE_WIDTH + 2) + 'px',
			top: '11px',
			width: '12px',
			height: '12px',
			cursor: 'pointer',
			zIndex: '1000',
			margin: 0,
			padding: 0,
			border: 'none'
		});
		close_button.onclick = this.hide.bind(this);
		
		this.view.appendChild(close_button);
/*		
		var transparent = document.createElement('img');
		Element.Methods.setStyle(transparent, {
			position: 'absolute',
			left: '0px',
			top: '0px',
			width: '249px',
			height: '252px',
			zIndex: this.z_index
		});
		transparent.src = 'images/transparent.gif';
		this.view.appendChild(transparent);
*/
		this.body = document.createElement('div');
		Element.Methods.setStyle(this.body, {
			position: 'absolute',
			left: '16px',
			top: '16px',
			width: (BUBBLE_WIDTH - 16) + 'px',
			height: BUBBLE_BODY_HEIGHT + 'px',
			zIndex: this.z_index + 3,
			backgroundColor: 'white',
			overflow: 'auto'
		});
		this.body.id = 'map_bubble_body';
		this.view.appendChild(this.body);
	},
	
	create_corner: function (left, top, height, width, image_left, image_top) {
		var div_ele = document.createElement('div');
		Element.Methods.setStyle(div_ele, { 
			position:'absolute',
			overflow: 'hidden',
			width: width + 'px',
			height: height + 'px',
			left: left + 'px',
			top: top + 'px',
			border: 'none',
			zIndex: this.z_index + 1
		})
		
		var img = document.createElement('img');
		if ( /MSIE/.test(navigator.userAgent) && !window.opera) {
			var inner_div = document.createElement('div');
			Element.Methods.setStyle (inner_div, {
				border: 'none',
				margin: 0,
				padding: 0,
				position: 'absolute',
				left: image_left + 'px',
				top: image_top + 'px',
				width: '690px',
				height: '786px',
				filter: "progid:DXImageTransform.Microsoft.AlphaImageLoader(sizingMethod=crop, src='/images/bubble.png')"				
			});
			img.style['visibility'] = 'hidden';
			div_ele.appendChild (inner_div);
 		} else {
			Element.Methods.setStyle (img, {
				border: 'none',
				margin: 0,
				padding: 0,
				position: 'absolute',
				left: image_left + 'px',
				top: image_top + 'px',
				width: '690px',
				height: '786px'
			});
			img.src='/images/bubble.png';
			div_ele.appendChild(img);
		}
		return div_ele;
	},
	
	create_border: function (left, top, height, width) {
		var div_ele = document.createElement('div');
		Element.Methods.addClassName(div_ele, 'bubble_border');
		Element.Methods.setStyle (div_ele, {
			left: left + 'px',
			top: top + 'px',
			height: height + 'px',
			width: width + 'px',
			zIndex: this.z_index
		});
		return div_ele;
	},
	
	hide: function () {
		Element.hide(this.view);
		this.visible = false;
	},
	
	show: function (x, y, html) {
		this.body.update(html);
		var nw_x = x-(BUBBLE_WIDTH - 98)/2 - 5;
		var nw_y = y-BUBBLE_HEIGHT;
		this.position = this.map.current_zoom_level.zoom_level_to_map(x, y);
		Element.Methods.setStyle (this.view, {
			left: nw_x + 'px',
			top: nw_y + 'px'
		});
		Element.show(this.view);
		this.visible = true;
	},
	
	move_to: function (x, y) {
		var nw_x = x-(BUBBLE_WIDTH - 98)/2 - 5;
		var nw_y = y-BUBBLE_HEIGHT;
		this.position = this.map.current_zoom_level.zoom_level_to_map(x, y);
		Element.Methods.setStyle (this.view, {
			left: nw_x + 'px',
			top: nw_y + 'px'
		});
	},
	
	zoom_level_changed: function(new_zoom_level) {
		if (this.position) {
			var new_xy = new_zoom_level.map_to_zoom_level(this.position[0], this.position[1]);
			this.view.setStyle ({
				left: (new_xy[0] - (BUBBLE_WIDTH - 98)/2 - 5) + 'px',
				top: (new_xy[1] - BUBBLE_HEIGHT) + 'px'
			});
		}
	}
	
});

var SlideControl = Class.create ();

SlideControl.POSITIONS= new Array(85, 101, 116, 131, 145, 162, 176, 189, 200);

Object.extend (SlideControl.prototype, {
	event_handlers : new Array (),
	moving: false,
	
	initialize: function (map) {
		this.map = map;
		this.create_view();
		this.event_handlers[0] = new Array(21, 81, 37, 208, { click: this.slide_clicked });
		this.event_handlers[1] = new Array(22, 62, 38, 78, { click: this.zoom_in });
		this.event_handlers[2] = new Array(22, 207, 38, 228, { click: this.zoom_out });
		this.event_handlers[3] = new Array(7,18,22,33, {click: this.move_left});
		this.event_handlers[4] = new Array(22, 33, 37, 48, {click: this.move_down});
		this.event_handlers[5] = new Array(37, 18, 52, 33, {click: this.move_right});
		this.event_handlers[6] = new Array(22, 3, 37, 18, {click: this.move_up});
	},
	
	create_view: function () {
		this.view=document.createElement ('div');
		Element.Methods.setStyle (this.view, {
			position: 'absolute',
			left: '5px',
			top: '5px',
			width: '59px',
			height: '230px'
		});
		
	    this.control_img = document.createElement ('img');
		this.control_img.src = "/images/map_control.jpg";
		this.view.appendChild(this.control_img);
		
		this.slide_block = document.createElement ('div');
		Element.Methods.setStyle (this.slide_block, {
			position: 'absolute',
			width: '16px',
			height: '8px',
			left: '21px',
			top: (SlideControl.POSITIONS[0] - 4) + 'px'
		});
		this.view.appendChild (this.slide_block);
		
		var slide_block_img = document.createElement('img');
		slide_block_img.src = "/images/slide_block.jpg"
		this.slide_block.appendChild (slide_block_img);
		
		this.view.onclick = this.on_click.bind(this);
//		this.view.onmousedown = this.on_mouse_down.bind(this);
//		this.view.onmousemove = this.on_mouse_move.bind(this);
//		this.view.onmouseup = this.on_mouse_up.bind(this);
	},
	
	set_zIndex: function (zIndex) {
		this.view.style['zIndex'] = zIndex;
		this.control_img.style['zIndex'] = zIndex;
		this.slide_block.style['zIndex'] = zIndex + 1;
	},
	
	on_click: function (event) {
		if (! event)  event = window.event;
		var view_pos = Position.page(this.view);
		var x = event.clientX - view_pos[0];
		var y = event.clientY - view_pos[1];
		var event_handler = this.get_event_handler (x, y, 'click');
		if (event_handler)
			event_handler.call (this, x, y);
	},
	
	on_mouse_down: function (event) {
		if (!event) event = window.event;
		var view_pos = Position.page(this.view);
		var x = event.clientX - view_pos[0];
		var y = event.clientY - view_pos[1];
		var left = stripPx(this.slide_block.style.left);
		var top = stripPx(this.slide_block.style.top);
		if (x >= left &&
			y >= top &&
			x <= left + 16 &&
			y <= top + 8) {
			this.moving = true;
			this.mouse_point_offset = y - top;
			this.start_y = event.clientY;
			return false;
		}
		return true;
	},
	
	on_mouse_up: function(event) {
		this.moving = false;
		return false;
	},
	
	on_mouse_move: function (event) {
		if (!event) event = window.event;
		$('debug').innerHTML = this.moving;
		if (this.moving) {
			var view_pos = Position.page(this.view);
			var x = event.clientX - view_pos[0];
			var y = event.clientY - view_pos[1];
			var new_top = (y - this.mouse_point_offset);
			if (new_top < 81) new_top = 81;
			if (new_top > 196) new_top = 196;
			this.slide_block.style.top =  new_top + 'px';
			this.start_y = event.clientY;
			return false;
		}
		return true;
	},
	
	get_event_handler: function (x, y, event_type) {
		for (var i=0; i< this.event_handlers.length; ++i) {
			if (x >= this.event_handlers[i][0] &&
				y >= this.event_handlers[i][1] &&
				x <= this.event_handlers[i][2] &&
				y <= this.event_handlers[i][3] )
				return this.event_handlers[i][4][event_type];
		}
	},
	
	slide_clicked: function (x, y) {
		for (var i=0; i<SlideControl.POSITIONS.length; ++i) {
			if (y >= SlideControl.POSITIONS[i] - 7 && 
				y <= SlideControl.POSITIONS[i] + 7 )
				break;
		}
		if (i < SlideControl.POSITIONS.length) {
			this.slide_block.style.top = (SlideControl.POSITIONS[i] - 4) + 'px';
			this.map.zoom_to ( SlideControl.POSITIONS.length - i - 1);
		}
	},
	
	set_zoom_level_index: function (index) {
		this.slide_block.style.top = (SlideControl.POSITIONS[ SlideControl.POSITIONS.length -index - 1] - 4) + 'px';
	},
	
	zoom_in: function (x, y) {
		this.map.zoom_in ();
		this.set_zoom_level_index (this.map.current_zoom_level_index);
	},
	
	zoom_out: function (x,y) {
		this.map.zoom_out ();
		this.set_zoom_level_index (this.map.current_zoom_level_index);
	},
	
	move_left: function (x,y) {
		this.map.move (128, 0);
	},
	
	move_down: function (x, y) {
		this.map.move(0, -128);
	},
	
	move_right: function () {
		this.map.move (-128, 0);
	},
	
	move_up : function () {
		this.map.move (0, 128);
	},
	
	is_slider: function () {
		return true;
	}
});


