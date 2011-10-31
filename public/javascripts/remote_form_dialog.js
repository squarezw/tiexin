var RemoteFormDialog = Class.create ();

Object.extend (RemoteFormDialog.prototype, {
  default_options : {
	  dialog_body: 'dialog_body',
	  dialog_head: 'dialog_head',
      width: "600px",
      fixedcenter: true,
      visible: false,
      constraintoviewport : true,
      modal: true,
	  zIndex: 3000
  },

  initialize: function(dialog_div_id, options) {       
    this.options = this.default_options;
    Object.extend(this.options, options);
    this.dialog = new YAHOO.widget.Dialog(dialog_div_id, this.options);  
    this.dialog.callback = { success: this.on_success.bind(this),
    					  failure: this.on_failure.bind(this) }
    this.dialog.asyncSubmitEvent.subscribe(this.on_submit, null, this);
    this.dialog.render();                    
  },

  retrieve_remote_form: function (url, options) {
	options = Object.extend ({method: 'get', evalScripts: true}, options);
	new Ajax.Updater (this.options.dialog_body,url,options);
  },

  show_with_title: function (title) {
	Element.update (this.options.dialog_head, title);
	this.dialog.registerForm();
	this.dialog.show();  
  },

  show: function () {
  	this.dialog.show();
  },

  hide: function () {
	this.dialog.hide();
  },

	on_submit: function () {
		Ajax.activeRequestCount ++;
		this.options.busy_indicator.task_start ();
	},

	on_success : function (resp) {
		Ajax.activeRequestCount --;
		this.options.busy_indicator.task_end ();
		eval_js_on_success (resp);
	},
	
	on_failure : function (resp) {
		Ajax.activeRequestCount --;
		this.options.busy_indicator.task_end ();
		show_status_on_error (resp);
	}
});

var RemotePanel = Class.create ();

Object.extend (RemotePanel.prototype, {
  default_options : {
	  body: 'panel_body',
	  head: 'panel_head',
      width: "600px",
      fixedcenter: false,
      visible: false,
      constraintoviewport : true,
      modal: false,
	  draggable: true,
	  zIndex: 1000
  },

  initialize: function(id, options) {       
    this.options = this.default_options;
    Object.extend(this.options, options);
    this.panel = new YAHOO.widget.Panel(id, this.options);  
    this.panel.callback = { success: eval_js_on_success,
    					  failure: show_status_on_error };

    this.panel.render();                    
  },

  retrieve: function (url, options) {
	options = Object.extend ({method: 'get', evalScripts: true}, options);
	new Ajax.Updater (this.options.body,url,options);
  },

  show_with_title: function (title) {
	Element.update (this.options.head, title);
	this.panel.show();  
  },

  show: function () {
  	this.panel.show();
  },

  hide: function () {
	this.panel.hide();
  }
});
