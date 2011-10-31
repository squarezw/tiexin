var InsertVariableCommand=function(){
//create our own command, we dont want to use the FCKDialogCommand because it uses the default fck layout and not our own
};
InsertVariableCommand.GetState=function() {
return FCK_TRISTATE_OFF; //we dont want the button to be toggled
}
InsertVariableCommand.Execute=function() {
  parent.quick_upload()
}
FCKCommands.RegisterCommand('quickUpload', InsertVariableCommand ); //otherwise our command will not be found
var oInsertVariables = new FCKToolbarButton('quickUpload', 'insert image');
oInsertVariables.IconPath = FCKConfig.PluginsPath + 'quickUpload/image.gif'; //specifies the image used in the toolbar
FCKToolbarItems.RegisterItem( 'quickUpload', oInsertVariables );

function quick_upload_insert_img(editor, image_url,alt){
    var oEditor = FCKeditorAPI.GetInstance(editor) ;
    oEditor.InsertHtml('<img src="'+image_url+'" alt="'+alt+'" >') ;
}