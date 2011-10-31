module HotelsHelper
  def safe_hotel_icon(hotel)
    hotel.photo ? image_tag(hotel.photo.mobile.url) : image_tag('nopic.jpg')
  end

  def safe_hotel_map(hotel, number)
    image_tag(safe_map_url(hotel,number))
  end

  def safe_map_url(hotel,number)
    hotel["map_#{number}"] ? hotel.send("map_#{number}").mobile.url : 'nopic.jpg'
  end

  def get_cities_js_array(cities)
     data = Array.new

    cities.each { |category|
       data[category.id] = []
       district = District.find_all_by_city_id(category.id)
       if district
         district.each{ |children|
           data[category.id].concat([{"txt" => localized_description(children, :name), "val" => children.id}])
         }         
       end
     }
     return data
  end
  
  def root_select_tag(name, category=nil, include_blank=false, blank_option=['', ''] )
    if category
        default_value = category.id
    else
      default_value = nil
    end
    html = category_root_select_tag_initial_js
    html << "<select name='#{name}' onchange=\"if(this.value != '') setChildren(category_children,this.options[this.selectedIndex].value,'#{_('Please select one')}');\">\n"
    options = City.find(:all,:select=>"id,name_#{@current_lang}",:conditions => "has_map = false").collect{|cat|  [localized_description(cat, :name),cat.id]}
    options.insert(0, blank_option) if include_blank
    html << options_for_select(options,default_value)
    html << "</select>\n"
  end
  
  def category_root_select_tag_initial_js
    html = "<script language='javascript'>  
                 /*  说明：将指定下拉列表的选项值清空
                  * @param {String || Object]} selectObj 目标下拉选框的名称或对象，必须  
                  */ 
                  removeOptions = function (selectObj) {
                    if (typeof selectObj != 'object')     {
                    selectObj = document.getElementById(selectObj);
                  } // 原有选项计数
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
                setSelectOption = function (selectObj, optionList, firstOption, selected) {     
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
                // 选中项         
                if(selected == optionList[i].val)         
                {            
                    selectObj.options[start].selected = true;         
              }         
                 // 计数加 1         
                start ++;     
                }
          }  //-->\n"
    html << "var catArr = #{get_cities_js_array(City.find(:all,:select=>"id,name_#{@current_lang}",:conditions => "has_map = false")).to_json};\n"
    html << "setChildren = function(selectObj,province,defaultValue) {setSelectOption(selectObj, catArr[province], defaultValue);}\n"
    html << "</script>\n"
  end

  def children_select_tag(name, object, include_blank=false, blank_option=['', ''] )
    default_value = nil
    categories = nil
    
    if object.city
      categories = object.city.districts
      default_value = object.district_id
    end
    
    html = "<select name='#{name}' id='category_children'>\n"
    options = []
    options = categories.collect{|cat|  [localized_description(cat,:name),cat.id]} if categories
    options.insert(0, blank_option) if include_blank
    html << options_for_select(options,default_value)
    html << "</select>\n"
  end
  
end
