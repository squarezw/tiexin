<!--  
  /*  说明：将指定下拉列表的选项值清空
   * @param {String || Object]} selectObj 目标下拉选框的名称或对象，必须  
  */ 
  function removeOptions(selectObj) {
      if (typeof selectObj != 'object')     {
          selectObj = document.getElementById(selectObj);    
      }
      // 原有选项计数     
      var len = selectObj.options.length;  
      for (var i=0; i < len; i++)     {        
          // 移除当前选项   
          selectObj.options[0] = null;     
      } 
  } 
  /*  说明：设置传入的选项值到指定的下拉列表中  
   *  @param {String || Object]} selectObj 目标下拉选框的名称或对象，必须  
   *  @param {Array} optionList 选项值设置 格式：[{txt:'北京', val:'010'}, {txt:'上海', val:'020'}] ，必须  
   *  @param {String} firstOption 第一个选项值，如：“请选择”，可选，值为空  
   *  @param {String} selected 默认选中值，可选  
  */
  function setSelectOption(selectObj, optionList, firstOption, selected) {     
      if (typeof selectObj != 'object')     {         
          selectObj = document.getElementById(selectObj);     }      
          // 清空选项     
          removeOptions(selectObj);      
          // 选项计数     
          var start = 0;          
          // 如果需要添加第一个选项     
          if (firstOption)     {
              selectObj.options[0] = new Option(firstOption, '');          
              // 选项计数从 1 开始        
              start ++;    
          }      
          var len = optionList.length;   
          for (var i=0; i < len; i++)     {        
              // 设置 option         
              selectObj.options[start] = new Option(optionList[i].txt, optionList[i].val);          
              //// 选中项         
              if(selected == optionList[i].val)         
              {            
                  selectObj.options[start].selected = true;         
              }         
              // 计数加 1         
              start ++;     
          }
}  //-->
