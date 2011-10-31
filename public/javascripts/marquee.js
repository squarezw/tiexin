var Marquee = Class.create ();

Marquee.prototype = {
	initialize : function (element, options) {
		this.options = {
			direction: 'left',
			speed: 50
		};
		
		this.element = $(element);
		Object.extend (this.options, options);
		if (this.element && this.need_marquee()) {
			this.content_element = document.createElement('div');
			this.content_element.innerHTML = this.element.innerHTML;
			this.buffer_element = document.createElement('div');
			this.buffer_element.innerHTML = this.element.innerHTML;
			this.element.innerHTML = '';
			if (this.options.direction == 'left' ||
			    this.options.direction == 'right') {
				var table = document.createElement('table');
				this.element.appendChild(table);
				var tbody = document.createElement('tbody');
				table.appendChild(tbody);
				var tr = document.createElement('tr');
				tbody.appendChild(tr);
				var td = document.createElement('td');
				tr.appendChild(td);
				td.appendChild(this.content_element);
				td = document.createElement('td');
				tr.appendChild(td);
				td.appendChild(this.buffer_element);
			} else {
				this.element.appendChild(this.content_element);
				this.element.appendChild(this.buffer_element);
			}
			this.timer = setInterval(this.run.bind(this), this.options.speed);
			this.element.onmouseover = this.onmouseover.bind(this);
			this.element.onmouseout = this.onmouseout.bind(this);
		}
	},
	
	need_marquee : function () {
		switch (this.options.direction) {
			case 'left':
			case 'right':
				return this.element.scrollWidth > this.element.offsetWidth;
			case 'up':
			case 'down':
				return this.element.scrollHeight > this.element.offsetHeight;
		}
	},
	
	onmouseover : function () {
		if (this.timer)
			clearInterval(this.timer);
	},
	
	onmouseout : function () {
		this.timer = setInterval(this.run.bind(this), this.options.speed);
	},
	
	stop: function () {
		if (this.timer)
			clearInterval(this.timer);
	},
	
	run : function () {
//		$('debug').innerHTML = this.element.scrollTop + "," + this.buffer_element.offsetHeight;
		switch (this.options.direction) {
			case 'left':
				if (this.buffer_element.offsetWidth - this.element.scrollLeft <= 0)
					this.element.scrollLeft -= this.content_element.offsetWidth;
				else
					this.element.scrollLeft++;
				break;
			case 'up':
				if (this.buffer_element.offsetHeight < this.element.scrollTop)
					this.element.scrollTop -= this.buffer_element.offsetHeight;
				else
					this.element.scrollTop ++;
		}
	}
}
