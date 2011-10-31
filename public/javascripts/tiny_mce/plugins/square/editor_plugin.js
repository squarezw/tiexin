/**
 * Author: Squarezw@yahoo.com.cn
 * 2010.5.25
 */

(function(tinymce) {
	tinymce.create('tinymce.plugins.SquarePlugin', {
		init : function(ed, url) {
			var t = this;

			t.editor = ed;

			// Register commands
			ed.addCommand('mceSquare', function() {
				ed.windowManager.open({
					file : url + '/square.htm',
					width :  325,
					height : 140,
					inline : 1
				}, {
					plugin_url : url
				});
			});

			ed.addCommand('mceInsertSquare', t._insertSquare, t);

			// Register buttons
			ed.addButton('square', {title : '插入图片', cmd : 'mceSquare'});
		}
	});

	// Register plugin
	tinymce.PluginManager.add('square', tinymce.plugins.SquarePlugin);
})(tinymce);