// bbCode control by
// subBlue design
// www.subBlue.com

// Startup variables
var imageTag = false;
var theSelection = false;

// Check for Browser & Platform for PC & IE specific bits
// More details from: http://www.mozilla.org/docs/web-developer/sniffer/browser_type.html
var clientPC = navigator.userAgent.toLowerCase(); // Get client info
var clientVer = parseInt(navigator.appVersion); // Get browser version

var is_ie = ((clientPC.indexOf("msie") != -1) && (clientPC.indexOf("opera") == -1));
var is_nav = ((clientPC.indexOf('mozilla')!=-1) && (clientPC.indexOf('spoofer')==-1)
                && (clientPC.indexOf('compatible') == -1) && (clientPC.indexOf('opera')==-1)
                && (clientPC.indexOf('webtv')==-1) && (clientPC.indexOf('hotjava')==-1));
var is_moz = 0;

var is_win = ((clientPC.indexOf("win")!=-1) || (clientPC.indexOf("16bit") != -1));
var is_mac = (clientPC.indexOf("mac")!=-1);

// Helpline messages
b_help = "粗体: [b]文字[/b]  (alt+b)";
i_help = "斜体: [i]文字[/i]  (alt+i)";
u_help = "下划线: [u]文字[/u]  (alt+u)";
q_help = "引用文字: [quote]文字[/quote] 或者 [code=\"javaeye\"]文字[/code]  (alt+q)";
c_help = "程序代码: [code]代码[/code] 或者 [code=\"ruby\"]代码[/code] (alt+c)";
l_help = "列表: [list] [*]文字 [*]文字 [*]文字 [/list] (alt+l)";
o_help = "顺序列表: [list=1] [*]文字  [/list] 或者 [list=A] [*]文字 [/list] (alt+o)";
p_help = "插入图像: [img]http://image_url[/img]  (alt+p)";
w_help = "插入URL: [url]http://url[/url] 或 [url=http://url]URL文字[/url]  (alt+w)";
a_help = "关闭所有开启的 BBCode 标签";
s_help = "字体颜色: [color=red]文字[/color]  提示：您可以使用 color=#FF0000";
f_help = "字体大小: [size=x-small]小字体文字[/size]";

// Define the bbCode tags
bbcode = new Array();
bbtags = new Array('[b]','[/b]','[i]','[/i]','[u]','[/u]','[quote]','[/quote]','[code]','[/code]','[email]','[/email]','[email=]','[/email]','[img]','[/img]','[url]','[/url]');
imageTag = false;

// Shows the help messages in the helpline window
function helpline(help) {
	document.post.helpbox.value = eval(help + "_help");
}


// Replacement for arrayname.length property
function getarraysize(thearray) {
	for (i = 0; i < thearray.length; i++) {
		if ((thearray[i] == "undefined") || (thearray[i] == "") || (thearray[i] == null))
			return i;
		}
	return thearray.length;
}

// Replacement for arrayname.push(value) not implemented in IE until version 5.5
// Appends element to the array
function arraypush(thearray,value) {
	thearray[ getarraysize(thearray) ] = value;
}

// Replacement for arrayname.pop() not implemented in IE until version 5.5
// Removes and returns the last element of an array
function arraypop(thearray) {
	thearraysize = getarraysize(thearray);
	retval = thearray[thearraysize - 1];
	delete thearray[thearraysize - 1];
	return retval;
}


function checkForm() {

	formErrors = false;

	if (document.post.message.value.length < 2) {
		formErrors = "您发表的文章必须有内容。";
	}

	if (formErrors) {
		alert(formErrors);
		return false;
	} else {
		bbstyle(-1);
		//formObj.preview.disabled = true;
		//formObj.submit.disabled = true;
		return true;
	}
}

function smile_icon(editorArea, id) {
	var txtarea = $(editorArea);
	text = '[smile=' + id + '/]';
	if ((clientVer >= 4) && is_ie && is_win) {
		theSelection = document.selection.createRange().text;
		if (!theSelection) {
			txtarea.value += text;
			txtarea.focus();
			return;
		}
		document.selection.createRange().text = text + theSelection
		txtarea.focus();
		return;
	}
	else if (txtarea.selectionEnd && (txtarea.selectionEnd - txtarea.selectionStart > 0))
	{
		mozWrap(txtarea,text, '');
		return;
	}
	else
	{
		txtarea.value += text;
		txtarea.focus();
	}
	storeCaret(txtarea);
}

function bbfontstyle(editorArea, bbopen, bbclose) {
	var txtarea = $(editorArea);

	if ((clientVer >= 4) && is_ie && is_win) {
		theSelection = document.selection.createRange().text;
		if (!theSelection) {
			txtarea.value += bbopen + bbclose;
			txtarea.focus();
			return;
		}
		document.selection.createRange().text = bbopen + theSelection + bbclose;
		txtarea.focus();
		return;
	}
	else if (txtarea.selectionEnd && (txtarea.selectionEnd - txtarea.selectionStart > 0))
	{
		mozWrap(txtarea, bbopen, bbclose);
		return;
	}
	else
	{
		txtarea.value += bbopen + bbclose;
		txtarea.focus();
	}
	storeCaret(txtarea);
}


function bbstyle(editorArea, button, bbnumber) {
//	var txtarea = document.post.message;
    var txtarea = $(editorArea);
	var frm = button.form;
	txtarea.focus();
	donotinsert = false;
	theSelection = false;
	bblast = 0;
	if (bbnumber == -1) { // Close all open tags & default button names
		while (bbcode[0]) {
			butnumber = arraypop(bbcode) - 1;
			txtarea.value += bbtags[butnumber + 1]; 
			but = eval("frm.addbbcode" + butnumber)
			buttext = but.value;
			but.value =  buttext.substr(0,(buttext.length - 1))
		}
		imageTag = false; // All tags are closed including image tags :D
		txtarea.focus();
		return;
	}

	if ((clientVer >= 4) && is_ie && is_win)
	{
		theSelection = document.selection.createRange().text; // Get text selection
		if (theSelection) {
			// Add tags around selection
			document.selection.createRange().text = bbtags[bbnumber] + theSelection + bbtags[bbnumber+1];
			txtarea.focus();
			theSelection = '';
			return;
		}
	}
	else if (txtarea.selectionEnd && (txtarea.selectionEnd - txtarea.selectionStart > 0))
	{
		mozWrap(txtarea, bbtags[bbnumber], bbtags[bbnumber+1]);
		return;
	}

	// Find last occurance of an open tag the same as the one just clicked
	for (i = 0; i < bbcode.length; i++) {
		if (bbcode[i] == bbnumber+1) {
			bblast = i;
			donotinsert = true;
		}
	}

	if (donotinsert) {		// Close all open tags up to the one just clicked & default button names
		while (bbcode[bblast]) {
				butnumber = arraypop(bbcode) - 1;           
				txtarea.value += bbtags[butnumber + 1];
				but = eval("frm.addbbcode" + butnumber)
				buttext = but.value;
				but.value =  buttext.substr(0,(buttext.length - 1))
				imageTag = false;
			}
			txtarea.focus();
			return;
	} else { // Open tags

		if (imageTag && (bbnumber != 14)) {		// Close image tag before adding another
			txtarea.value += bbtags[15];
			lastValue = arraypop(bbcode) - 1;	// Remove the close image tag from the list
			document.post.addbbcode14.value = "Img";	// Return button back to normal state
			imageTag = false;
		}

		// Open tag
		txtarea.value += bbtags[bbnumber];
		if ((bbnumber == 14) && (imageTag == false)) imageTag = 1; // Check to stop additional tags after an unclosed image tag
		arraypush(bbcode,bbnumber+1);                             
		button.value += "*";
		txtarea.focus();
		return;
	}
	storeCaret(txtarea);
}

// From http://www.massless.org/mozedit/
function mozWrap(txtarea, open, close)
{
	var selLength = txtarea.textLength;
	var selStart = txtarea.selectionStart;
	var selEnd = txtarea.selectionEnd;
	if (selEnd == 1 || selEnd == 2)
		selEnd = selLength;

	var s1 = (txtarea.value).substring(0,selStart);
	var s2 = (txtarea.value).substring(selStart, selEnd)
	var s3 = (txtarea.value).substring(selEnd, selLength);
	txtarea.value = s1 + open + s2 + close + s3;
	return;
}

// Insert at Claret position. Code from
// http://www.faqts.com/knowledge_base/view.phtml/aid/1052/fid/130
function storeCaret(textEl) {
	if (textEl.createTextRange) textEl.caretPos = document.selection.createRange().duplicate();
}
