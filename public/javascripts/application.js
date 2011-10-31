function eval_js_on_success(resp) {
	eval(resp.responseText);
}

function show_status_on_error(resp) {
	alert ("Server error:" + resp.responseText);
}                                         

function handleSubmit () {
	this.submit();
}   

function handleCancel () {
	this.cancel();
}

function show_hourglass(id) {
	$(id).update ("<image src='/public/images/ajaxloading.gif' />");
}

function hide_hourglass(id) {
	$(id).update('');
}

var BusyIndicator = Class.create ();

Object.extend (BusyIndicator.prototype, {
	initialize : function (img) {
		this.img = img;
		Element.hide(this.img);
		Ajax.Responders.register ({
			onLoading: this.task_start.bind(this),
			onComplete: this.task_end.bind(this)
		});
		this.request_count = 0;
	},
	
	task_start: function () {
		++ this.request_count;
		if (this.request_count >0)
			Element.show(this.img);
	},
	
	task_end: function () {
		if (this.request_count > 0)
			-- this.request_count;
		if (this.request_count <= 0) {
			Element.hide (this.img);
		}
	}
});

function fast_search(form) {     
	try {    
		if (big_map_page != undefined ) {   
			new Ajax.Request (
				form.action + "js", 
				{
					method: 'post',
					parameters: Form.serialize(form)
				}
			);
			return false;
		} else 
			form.submit ();
	} catch (e) {
		form.submit ();
	}
}

function refresh_captcha_img () {
	$('img_captcha').src='/captcha.jpg?' + new Date().getMilliseconds();
}

function key_submit (event) {
	if (!event) event=window.event;
	
 	if (event.keyCode == 13) {
		
	} else {
		return true;
	}
}

function stripPx(value) {           
	if (value == "") 
		return 0;   
	if (value.indexOf('px') >= 0 || value.indexOf('em') >= 0) {
		return parseFloat(value.substring(0, value.length - 2));                                     
    } else {
		return parseFloat(value);
	}
}

function input_with_help(text,input_id)
{
        var input_ctrl=$(input_id);
        input_ctrl.value = text;
        input_ctrl.onfocus = 
			function(event) {
				if (this.value==text) {  
					this.value=""; 
				    this.removeClassName("with_help");
				 }
			};
			
        input_ctrl.onblur = 
			function() { 
			  if (this.value=="") {
				this.value=text; 
				this.addClassName('with_help');
			  }
			};
			
		input_ctrl.addClassName("with_help");
}

function getRadioValue(radio) {
    if (!radio.length && radio.type.toLowerCase() == 'radio')
    {
        return (radio.checked)?radio.value:'';
    }
    if (radio[0].tagName.toLowerCase() != 'input' ||
        radio[0].type.toLowerCase() != 'radio')
    { return ''; }
    
    var len = radio.length;
    for(i=0; i<len; i++)
    {
        if (radio[i].checked)
        {
            return radio[i].value;
        }
    }
    return '';
} 

function mark_required_field() {
//	alert ("Is IE? " + Prototype.Browser.IE);
	if (Prototype.Browser.IE) {
		var labels = $$('label.required');
		for (i=0; i<labels.length; ++i) {
			var label = labels[i];
			label.innerHTML = label.innerHTML + '<span class="required_mark">*</span>';
		}
	}
}

function showhide(id){
    if (document.getElementById){
        obj = document.getElementById(id);
        if (obj.style.display == "none"){
            obj.style.display = "";
        }
        else
        {
            obj.style.display = "none";
        }
    }
}