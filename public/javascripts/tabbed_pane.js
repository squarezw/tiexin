var TabbedPane = Class.create ();

TabbedPane.prototype = {
	current_page: null,
	current_head: null,
	
	initialize: function (id) {
		var pages = $(id).getElementsByClassName('tab_page');
		$A(pages).each(function (p) { p.hide(); });
	},
	
	show_page: function (head_id, page_id) {
		if (this.current_page != null) 
			Element.hide(this.current_page);
		if (this.current_head != null) 
			Element.Methods.removeClassName(this.current_head, "selected");
		this.current_page = $(page_id);
		Element.show(this.current_page);
		this.current_head = $(head_id);
		Element.Methods.addClassName(this.current_head, "selected");
	}
}