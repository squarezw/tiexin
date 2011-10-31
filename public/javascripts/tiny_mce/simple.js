tinyMCE.init({
        // General options
        language: 'zh',
        mode : "textareas",
        editor_selector : "mceEditor",
        theme : "advanced",
        //plugins : "pagebreak,style,layer,table,save,advhr,advimage,advlink,emotions,iespell,inlinepopups,insertdatetime,preview,media,searchreplace,print,contextmenu,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,xhtmlxtras,template,wordcount,advlist,autosave",
        plugins:"media,table,emotions,contextmenu,fullscreen,inlinepopups,square",

        // Theme options
        theme_advanced_buttons1:"formatselect,fontselect,fontsizeselect,separator,forecolor,backcolor,separator,bold,italic,underline,strikethrough,separator,bullist,numlist,separator,justifyleft,justifycenter,justifyright,emotions",
        theme_advanced_buttons2:"",
        theme_advanced_buttons3:"",
        theme_advanced_toolbar_location : "top",
        theme_advanced_toolbar_align : "left",
        theme_advanced_fonts:"宋体=宋体;黑体=黑体;仿宋=仿宋;楷体=楷体;隶书=隶书;幼圆=幼圆;Arial=arial,helvetica,sans-serif;Comic Sans MS=comic sans ms,sans-serif;Courier New=courier new,courier;Tahoma=tahoma,arial,helvetica,sans-serif;Times New Roman=times new roman,times;Verdana=verdana,geneva;Webdings=webdings;Wingdings=wingdings,zapf dingbats",
        convert_fonts_to_spans:true,
        remove_trailing_nbsp:true,
        remove_linebreaks:false,
        width:"100%",
        extended_valid_elements:"pre[name|class],object[classid|codebase|width|height|align],param[name|value],embed[quality|type|pluginspage|width|height|src|align|wmode]",
        relative_urls:false,

        // Example content CSS (should be your site CSS)
        //content_css : "css/content.css",
        content_css: "/javascripts/tiny_mce/plugins/square/css/content.css",
        save_callback:"removeBRInPre"
});

function removeBRInPre(element_id,html,body){
return html.replace(/<pre([^>]*)>((?:.|\n)*?)<\/pre>/gi,function(a,b,c){
c=c.replace(/<br\s*\/?>\n*/gi,'\n');
return'<pre'+b+'>'+c+'</pre>';
});
}

