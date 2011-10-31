var XNaviMap = Class.create();                            

XNaviMap.prototype = { 
	zoom_levels: [],
	
	initialize: function (div_id, options) {
		this.options = {
			tile_size: 128,
			viewport_width: 640,
			viewport_height: 480
		};                       
		
		Object.extend (this.options, options || {});  
		

		var outer_div = $(div_id);          
		
		outer_div.style.width= this.options.viewport_width + 'px';
		outer_div.style.height= this.options.viewport_height + 'px';
		
	    outer_div.onmousedown=this.start_move.bind(this);
		outer_div.onmousemove=this.process_move.bind(this);
		outer_div.onmouseup=this.stop_move.bind(this);               
		outer_div.onclick=this.on_click.bind(this);    
		if ( /MSIE/.test(navigator.userAgent) && !window.opera) {
			document.onmouseup = this.stop_move.bind(this);
		} else {
			window.onmouseup = this.stop_move.bind(this);
		}

		outer_div.model = this;           
		

		/* Enable drag and drop in IE */		
		outer_div.ondragstart= function () {return false;}  

		this.inner_div = document.createElement('div');    
		this.inner_div.setAttribute('id', 'xnavi_inner');
//		this.inner_div.setStyle({zIndex : 10});		                                   
		this.inner_div.style['zIndex'] = 10;

        this.set_zoom_levels(this.options.zoom_level);

		this.tile_layer = new XTileLayer(10, this.options);
		
		this.inner_div.appendChild(this.tile_layer.view);
		                                                      
		this.marker_layer = new XMarkerLayer (this, 20);
		this.inner_div.appendChild(this.marker_layer.view);
		
		outer_div.appendChild (this.inner_div);  
		this.container = outer_div;
		
		this.dragging = false;                                      
		this.top = 0;
		this.left = 0;   
		                     
		this.check_tiles ();
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
		if (zoom_levels.length > 1)
			this.set_current_zoom_level_index(zoom_levels.length - 2);
		else
			this.set_current_zoom_level_index(zoom_levels.length - 1);
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
		
		var m = this.find_marker_contains(event.clientX, event.clientY);
		if (this.can_move_marker && m) {
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
//		this.inner_div.style.cursor = "-moz-grab";        
		this.dragging= true;
		return false;		
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
			new_top = Math.min(Math.max(new_top, 0),this.current_zoom_level.map_height);
			new_left = Math.min(Math.max(new_left, 0),this.current_zoom_level.map_width);
			this.process_move_marker(new_left, new_top);
		} else {                                                                 
			this.process_move_map (new_left , new_top);
		}		
		return false;
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
				new_pos = this.current_zoom_level.zoom_level_to_map(new_pos[0], new_pos[1]);
				this.fire_event(this.moving_marker, 
								new XEvent('marker_moved', new_pos[0], new_pos[1]));
			}
		}
		
		this.inner_div.style.cursor='';
		this.dragging = false;		        
		this.moving_marker = null;
		this.marker_to_be_moved = null;                   
		return false;
	},
	
	
	check_tiles : function  () {
		this.tile_layer.check_tiles(this.get_visible_tiles(), this.current_zoom_level);
	},
	
	get_visible_tiles : function  () {     
		var left = this.map_left();
		var top = this.map_top();
		if (left <=0 )
			var startX = Math.abs(Math.floor(this.map_left() / this.options.tile_size)) - 1;
		else
			var startX = 0;
		if (top <=0)
			var startY = Math.abs(Math.floor(this.map_top() / this.options.tile_size)) - 1;  
		else
			var startY = 0;
		
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
	add_marker: function (x, y, options) {
		return this.marker_layer.add_marker(x, y, options);
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
	
	zoom_in : function () {
		var old_status = this.preserve_status ();
		this.set_current_zoom_level_index(this.current_zoom_level_index - 1);
		if (old_status.zoom_level_index != this.current_zoom_level_index) {
            this.after_zoom(old_status);
		}
		this.restore_position(old_status);
	},

	zoom_out : function () {
		var old_status = this.preserve_status ();
		this.set_current_zoom_level_index(this.current_zoom_level_index + 1);
		if (old_status.zoom_level_index != this.current_zoom_level_index) {
			this.after_zoom(old_status);
		}
		this.restore_position(old_status);
	},         
	
	preserve_status: function () {
		return {
			zoom_level_index : this.current_zoom_level_index,
			scale : this.current_zoom_level.scale,      
			center: this.current_zoom_level.zoom_level_to_map (
				this.options.viewport_width / 2 - this.map_left() ,
				this.options.viewport_height / 2 - this.map_top() )
		};
	},
	
	after_zoom: function (old_status) {
		this.tile_layer.clear();
		this.check_tiles();                          
		this.marker_layer.zoom_level_changed(this.current_zoom_level);                       
	},
	
	restore_position: function(old_status) {
		var left = old_status.map_left / old_status.scale * this.current_zoom_level.scale;
		var top = old_status.map_top / old_status.scale * this.current_zoom_level.scale;
		this.set_position(old_status.center[0], old_status.center[1]);
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
	
	highlight_marker: function (marker) {
		this.marker_layer.highlight_marker (marker);
	},
	
	remove_marker: function (marker) {
		this.marker_layer.remove_marker (marker);
	},
	
	add_control: function (control) {
		this.container.appendChild(control.view);
		control.set_zIndex (1000);
	}
}   

var XTileLayer = Class.create ();

XTileLayer.prototype = {
	initialize: function (z_index, options) {
		this.view = document.createElement('div');
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
		var path = "/images/maps/" + Math.floor(zoom_level.id / 200) + "/" + zoom_level.id + "/" ;
		for (i=0; i < visibleTiles.length; i++) {      
			var tileArray = visibleTiles[i];
			var tileName="x" + tileArray[0] + "_y" + tileArray[1];
			visibleTilesMap[tileName] = true;
			var img=$(tileName);
			if (! img) {
				img = document.createElement("img");
				img.src= path + tileName + ".jpg";
				img.style.position="absolute";
				img.style.left = (tileArray[0] * this.options.tile_size) + "px";
				img.style.top = (tileArray[1] * this.options.tile_size) + "px";
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
			Element.Methods.remove (nodes[i]);
		}
	}
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
	
	add_marker: function (x, y, options) {
		var marker = new XMarker(this, x, y, xnavi_map.current_zoom_level, options);
		this.view.appendChild(marker.element);    
		this.markers.push(marker);
		return marker
	},
	
	remove_marker: function (marker) {
		marker.remove ();
		var idx = this.markers.indexOf(marker);
		if (idx > 0) {
			this.markers[idx] = null;
			this.markers.compact();
		}
	},
	                                        
	get_marker_by_property_value: function(property_name, property_value) {
		for (var i=0; i<this.markers.length; ++i) {
			if (this.markers[i] && this.markers[i].options[property_name] == property_value) { 
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
			marker.remove ();
		});                  
		this.markers = [];
		this.clear_highlighted_marker ();
	},
	
	zoom_level_changed: function (new_zoom_level) {
		for (var i=0; i< this.markers.length; ++i) {
			this.markers[i].zoom_level_changed(new_zoom_level);
		}
	},
	
	find_marker_contains : function (x, y) {
		for (var i=0; i<this.markers.length; ++i) {
			var marker = this.markers[i];
			if (marker && Position.within(this.markers[i].element, x, y))
				return this.markers[i];
		}   
		return null;
	},
	
    highlight_marker: function (marker) {
		if (marker == this.highlighted_marker)
			return;
		marker.highlight();
		if (this.highlighted_marker) {
			this.highlighted_marker.unhighlight ();
		}
		this.highlighted_marker = marker;
	},
	
	clear_highlighted_marker: function () {
		if (this.highlighted_marker) {
			this.highlighted_marker.unhighlight();
			this.highlighted_marker = null;
		}
	}
}           

var XMarker = Class.create();

Object.extend(XMarker.prototype, {
	initialize: function (container, x, y, zoom_level, options) {
		this.element = document.createElement('img');  
		this.options = Object.extend( {icon: '/images/default_category.gif'}, options);    
		this.container = container;                 
		this.element.model = this;
		this.element.id = 'marker_' + this.options.unique_id;
		this.element.src = this.options.icon;
		this.x = x;
		this.y = y;
                                              
		var point = zoom_level.map_to_zoom_level(x, y);
				
		Element.setStyle(this.element, {
			position: 'absolute',
			left: (point[0]-12) + 'px',
			top: (point[1]-12) + 'px',
			width: '24px',
			height: '24px'
		});         

		if (options.tooltip) {
			this.set_tooltip(this.options.tooltip);
		}                                    
		
		this.element.onclick=function (event) {
			if (!event) event=window.event;
			this.model.container.map.fire_event(this.model, new XEvent('click_marker', 0, 0));    
			return false;
		};   
	},    
	
	// (x, y) is in zoom_level coordination
	set_position : function (x, y) {
		Element.setStyle(this.element, {
			left : (x - 12) + 'px',
			top: (y - 12) + 'px'
		});
	},
	
	set_visible: function(visible) {
		this.element.style.display = visible ? '' : 'none';
	},
	
	set_tooltip: function(tooltip) {
		new YAHOO.widget.Tooltip ('tooltip_' + this.options.unique_id,
			{ context: this.element.id,
			  text: tooltip,
			  zIndex: 200 });
	},
	
	set_icon: function(icon) {
		this.element.src = icon;
	},
	
	remove : function () {
		this.element.remove ();
	},
	
	zoom_level_changed: function(new_zoom_level) {
		var point = new_zoom_level.map_to_zoom_level(this.x, this.y);
		Element.setStyle(this.element, {
			left: (point[0]-12) + 'px',
			top: (point[1]-12) + 'px'
		});
	},
	
	position: function () {
		return [ stripPx(this.element.style.left) + 12,
		         stripPx(this.element.style.top) + 12 ];
	},
	
	highlight: function () {
		this.element.setStyle ({ borderWidth: "2px",
							     borderStyle: "solid",
							     borderColor: "#0000FF"});
	},
	
	unhighlight: function () {
		this.element.setStyle ({ border: "none"});
	}
});                           

var XEvent = Class.create();

XEvent.prototype = {
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
	map_width: 0,
	map_height: 0,
	scale: 1,
	
	initialize: function (map, options) {
		Object.extend(this, options);
		this.tile_columns = Math.ceil(this.map_width / map.options.tile_size);
		this.tile_rows = Math.ceil(this.map_height / map.options.tile_size);
	},
	                                             
	// Return coordination of center point, in zoom level's coordination system.
	center : function () {
		return [this.map_width / 2, this.map_height / 2];
	},
	                                                                            
	// Convert map coordination to zoom_level coordination.
	map_to_zoom_level: function (x, y) {
		return [x * this.scale, y * this.scale];
	},
	
	// Convert zoom level coordination to map coordination
	zoom_level_to_map: function (x, y) {
		return [x / this.scale, y / this.scale];
	}
});

var SlideControl = Class.create ();

Object.extend (SlideControl.prototype, {
	event_handlers : new Array (),
	moving: false,
	
	initialize: function (map) {
		this.map = map;
		this.create_view();
		this.event_handlers[0] = new Array(21, 55, 37, 71, { click: this.zoom_in });
		this.event_handlers[1] = new Array(21, 85, 37, 101, { click: this.zoom_out });
		this.event_handlers[2] = new Array(7,18,22,33, {click: this.move_left});
		this.event_handlers[3] = new Array(22, 33, 37, 48, {click: this.move_down});
		this.event_handlers[4] = new Array(37, 18, 52, 33, {click: this.move_right});
		this.event_handlers[5] = new Array(22, 3, 37, 18, {click: this.move_up});
	},
	
	create_view: function () {
		this.view=document.createElement ('div');
		Element.Methods.setStyle (this.view, {
			position: 'absolute',
			left: '5px',
			top: '5px',
			width: '59px',
			height: '117px'
		});
		
	    
	if ( Prototype.Browser.IE ) {
		this.control = document.createElement('div');
		Element.Methods.setStyle (this.control, {
			border: 'none',
			margin: 0,
			padding: 0,
			position: 'absolute',
			left: '0px',
			top: '0px',
			width: '59px',
			height: '117px',
			filter: "progid:DXImageTransform.Microsoft.AlphaImageLoader(sizingMethod=crop, src='/images/layout_maps/slide_control.png')"				
		});
		this.view.appendChild(this.control);
	} else {
		this.control = document.createElement ('img');
		Element.Methods.setStyle (this.control, {
			border: 'none',
			margin: 0,
			padding: 0,
			position: 'absolute',
			left: '0px',
			top: '0px',
			width: '59px',
			height: '117px'
		});
		this.control.src = "/images/layout_maps/slide_control.png";
		this.view.appendChild(this.control);
	}
		
		
		this.view.onclick = this.on_click.bind(this);
	},
	
	set_zIndex: function (zIndex) {
		this.view.style['zIndex'] = zIndex;
		this.control.style['zIndex'] = zIndex;
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
	
	get_event_handler: function (x, y, event_type) {
		for (var i=0; i< this.event_handlers.length; ++i) {
			if (x >= this.event_handlers[i][0] &&
				y >= this.event_handlers[i][1] &&
				x <= this.event_handlers[i][2] &&
				y <= this.event_handlers[i][3] )
				return this.event_handlers[i][4][event_type];
		}
	},
	
	zoom_in: function (x, y) {
		this.map.zoom_in ();
	},
	
	zoom_out: function (x,y) {
		this.map.zoom_out ();
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



