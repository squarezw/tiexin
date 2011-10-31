function add_and_show_model_marker (map, model, option) {
	var marker = new ModelMarker(model, option);
	marker.show(map);
	return marker;
}

var ModelMarkerManager = {
	model_markers : [],

	registe_model_marker: function (marker) {
		this.model_markers[this.model_markers.length] = marker;
	},

	index_of_id: function (identity) {
		for (i=0; i< this.model_markers.length; ++i) {
			if (this.model_markers[i] && this.model_markers[i].identity === identity)
				return i;
		}
		return -1;
	},

	marker_of_id: function (identity) {
		var idx = this.index_of_id(identity);
		if (idx >= 0) {
			return this.model_markers[idx];
		} else {
			return undefined;
		}
	},

	remove_model_marker: function (identity) {
		var idx = this.index_of_id(identity);
		if (idx >= 0) {
			this.model_markers[idx].remove ();
			this.model_markers[idx] = null;
			this.compact ();
		}
	},

	remove_model_of_type: function (type) {
		for (i=0; i<this.model_markers.length; ++i) {
			if (this.model_markers[i].model.type_name == type ) {
				this.model_markers[i].remove();
				this.model_markers[i] = null;
			}
		}
		this.compact ();
	},

	remove_all: function () {
		for (i=this.model_markers.length - 1; i >= 0; --i) {
			if (this.model_markers[i])
				this.model_markers[i].remove ();
		}
		this.model_markers = [];
	},

	compact: function () {
		this.model_markers = this.model_markers.compact();
	}
}

var ModelMarker = Class.create ();

ModelMarker.prototype = {
	initialize: function (model, options) {
		this.identity = model.identity;
		this.model = model;
		var latlng = new GLatLng(model.latitude, model.longitude);
		options.title = model.label;
		this.marker = new GMarker(latlng, options);
		this.marker.model = this;
		ModelMarkerManager.registe_model_marker(this);
	},

	show: function (map) {
		map.addOverlay (this.marker);
		this.map = map;
	},

	remove: function () {
		this.map.removeOverlay(this.marker);
	},

	update_model: function (model) {
		this.map.removeOverlay(this.marker);
		this.identity = model.identity;
		this.model = model;
		var latlng = new GLatLng(model.latitude, model.longitude);
		this.marker = new GMarker(latlng, { title: model.label });
		this.marker.model = this;
		this.show(this.map);
	},

	open_infor_window: function (options) {
		if (this.model.inforWindowContent) {
			this.marker.openInfoWindow(this.model.inforWindowContent, options);
		}
	}
}

var GMapContextMenu = Class.create ();

GMapContextMenu.prototype = {
	initialize: function (map, links) {
			this.map = map;
			var that=this;

			this.contextmenu = document.createElement("div");
			this.contextmenu.style.display="none";
		//CSS class name of the menu
			this.contextmenu.className="gmap_context_menu";
			this.ul_container = document.createElement("ul");
			this.ul_container.id="gmap_context_menu_ul";
			this.contextmenu.appendChild(this.ul_container);
			this.create_links(links);
			this.map.getContainer().appendChild(this.contextmenu);

		//Event listeners that will interact with our context menu
			GEvent.addListener(this.map,"singlerightclick",function(pixel,tile) {
				that.positionLatLng = that.map.fromContainerPixelToLatLng(pixel);
				that.clickedPixel = pixel;
				var x=pixel.x;
				var y=pixel.y;
		//Prevents the menu to go out of the map margins, in this case the expected menu size is 150x110
				if (x > that.map.getSize().width - 160) { x = that.map.getSize().width - 160 }
				if (y >that.map.getSize().height - 120) { y = that.map.getSize().height - 120 }
				var pos = new GControlPosition(G_ANCHOR_TOP_LEFT, new GSize(x,y));
				pos.apply(that.contextmenu);
				that.contextmenu.style.display = "";
			});
			GEvent.addListener(this.map, "move", function() {
				that.contextmenu.style.display="none";
			});
			GEvent.addListener(this.map, "click", function(overlay,point) {
				that.contextmenu.style.display="none";
			});
	},

	create_links: function(links) {
		for (i=0; i<links.length; ++i) {
			this.create_link(links[i]);
		}
	},

	create_link: function(link) {
		var that=this;
		var a_link = document.createElement("li");
		a_link.innerHTML="<a href='#'>" + link.label + "</a>";
		GEvent.addDomListener(a_link, 'click', function() {
			eval(link.href);
			that.contextmenu.style.display='none';
		});
		this.ul_container.appendChild(a_link);
	},

	bind: function(method) {
		var self = this;
		var opt_args = [].slice.call(arguments, 1);
		return function() {
			var args = opt_args.concat([].slice.call(arguments));
			return method.apply(self, args);
		};
	}
}

function current_map_status(map) {
	return {
		center: map.getCenter(),
		zoom : map.getZoom(),
		mapType : map.getCurrentMapType()
	};
}

function set_map_status(map, status) {
	map.setCenter(status.center);
	map.setZoom(status.zoom);
	map.setMapType(status.mapType)
}

var GMapLabelManager = {
	labels: [],

	add_label: function (label) {
		this.labels[this.labels.length] = label;
	},

	remove_label: function(label) {
		for (i=0; i<this.labels.length; ++i) {
			if (this.labels[i] == label) {
				label.map_.removeOverlay(label);
				this.labels[i] = null;
			}
		}
		this.labels = this.labels.compact();
	},

	remove_all: function () {
		for (i=0; i<this.labels.length; ++i) {
			if (this.labels[i])
				this.labels[i].map_.removeOverlay(this.labels[i]);
		}
		this.labels = [];
	}
}

function GMapLabel(contentHtml, latitude, longitude, options) {
	this.contentHtml = contentHtml;
	this.latlng = new GLatLng(latitude, longitude);
	this.options = Object.extend({ opacity: 80, anchorPoint: 'topLeft' }, options);
}

Object.extend (GMapLabel.prototype, new GOverlay());

Object.extend (GMapLabel.prototype, {
	initialize: function (map) {
		var div = document.createElement('div');
		var span = document.createElement('span');
		span.innerHTML = this.contentHtml;
		div.appendChild(span);
		div.className = 'gmap_label';
		document.body.appendChild(div);
		this.w = $(span).offsetWidth;
		this.h = $(span).offsetHeight;
		div.style.width = this.w + 'px';
		div.style.height = this.h + 'px';

		div.style.position = 'absolute';
		document.body.removeChild(div);
		map.getPane(G_MAP_MAP_PANE).appendChild(div);
		this.map_ = map;
		this.div_ = div;
		this.setOpacity(this.options.opacity);
	},

	remove: function() {
		this.div_.parentNode.removeChild(this.div_);
	},

	copy: function() {
		return new GMapLabe(this.contentHtml, this.latlng.lat(), this.latlng.lng());
	},

	redraw: function (force) {
		if (!force) return;
		this.setPosition();
	},

	setPosition: function(){
		var b = this.map_.fromLatLngToDivPixel(this.latlng);
		var x = b.x;
		var y = b.y;
		with(Math) {
			switch(this.options.anchorPoint) {
				case 'topLeft': break;
				case 'topCenter': x -= floor(this.w/2);break;
				case 'topRight': x -= this.w;break;
				case 'midRight': x -= this.w;y-=floor(this.h/2);break;
				case 'bottomRight': x -= this.w;y-=this.h;break;
				case 'bottomCenter': x -= floor(this.w/2);y-=this.h;break;
				case 'bottomLeft': y -= this.h;break;
				case 'midLeft': y -= floor(this.h/2);break;
				case 'center': x -= floor(this.w/2);y-=floor(this.h/2);break;
				default:break;
			 }
		 }
		this.div_.style.left = x + 'px';
		this.div_.style.top = y + 'px';
	},

	setOpacity: function(b) {
		 if(b<0) {b=0;}
		 if (b>100) {b=100;}
		 var c=b/100;
		 if(typeof(this.div_.style.filter)=='string'){ this.div_.style.filter='alpha(opacity:'+b+')';}
		 if(typeof(this.div_.style.KHTMLOpacity)=='string'){this.div_.style.KHTMLOpacity=c;}
		 if(typeof(this.div_.style.MozOpacity)=='string'){this.div_.style.MozOpacity=c;}
		 if(typeof(this.div_.style.opacity)=='string'){this.div_.style.opacity=c;}
	}
});