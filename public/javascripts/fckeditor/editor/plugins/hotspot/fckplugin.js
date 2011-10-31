var InsertVariableCommand=function(){
//create our own command, we dont want to use the FCKDialogCommand because it uses the default fck layout and not our own
};
InsertVariableCommand.GetState=function() {
return FCK_TRISTATE_OFF; //we dont want the button to be toggled
}
InsertVariableCommand.Execute=function() {
  parent.show_hot_spots()
}
FCKCommands.RegisterCommand('hotspot', InsertVariableCommand ); //otherwise our command will not be found
var oInsertVariables = new FCKToolbarButton('hotspot', '插入地标');
oInsertVariables.Style = FCK_TOOLBARITEM_ICONTEXT
oInsertVariables.IconPath = FCKConfig.PluginsPath + 'hotspot/hot_spot.gif'; //specifies the image used in the toolbar
FCKToolbarItems.RegisterItem( 'hotspot', oInsertVariables );