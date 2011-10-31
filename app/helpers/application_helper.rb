# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper    
  def format_date(date)
    return '' if date.nil?
    return date.strftime('%Y-%m-%d') if date.respond_to?(:strftime)
    return date.to_formatted_s('%y-%m-%d') if date.respond_to?(:to_formatted_s)
    ''
  end        
  
  def date_range_str(s, e)
    result = ''
    result << format_date(s) unless s.nil?
    result << '&nbsp;' + _('To') + '&nbsp;' + format_date(e) unless s.nil?
    result
  end
  
  def format_time(time)
    time.nil? ? '' : time.strftime('%Y-%m-%d %H:%M')
  end
  
  def format_time_for_xml(time)
    time.nil? ? '' : time.strftime('%Y%m%d %H:%M:%S')    
  end
  
  def format_boolean_for_xml(b)
    b ? 'true' : 'false'
  end
  
  def row_id(obj)
    "#{obj.class.to_s}_#{obj.id}" 
  end               
  
  def element_id(obj)
    "ele_#{obj.class.to_s}_#{obj.id}"
  end                 
  
  def hotspot_category_select_tag(name, include_blank=false, blank_option=['', ''])
    html = "<select name='#{name}'>\n"
    options = options_for_select_hot_spot_category
    options.insert(0, blank_option) if include_blank
    html << options_for_select(options)
    html << "</select>\n"
  end           
  
  def root_categories
    @_root_categories ||= HotSpotCategory.roots
  end
  
  def root_category_choices
    root_categories.collect { |cat| [h(localized_description(cat, :name)), cat.id] }        
  end
  
  def root_category_select(object, method, options={})
    select object, method, root_category_choices, options
  end
  
  def root_category_select_tag(name, selected, options={})
    choices= root_category_choices
    if options[:include_blank]
      blank_option = options.delete :include_blank
      case blank_option
      when true 
        choices.insert 0, ['', '']
      when false
      else
        choices.insert 0, [blank_option.to_s, '']
      end
    end
    logger.info "choices = #{choices}"
    select_tag name, options_for_select(choices, selected), options
  end
  
  def hot_spot_category_select(object, method, options={}, html_options={})
    select(object, method, options_for_select_hot_spot_category, options, html_options)
  end        
 
  def options_for_select_hot_spot_category
    options=HotSpotCategory.roots.inject([]) { |collection, cat| collection.concat(cat.all_children_include_self) }                                                       
    options = options.collect { |cat| [hot_spot_category_label_with_level(cat), cat.id] }
  end

  def hotspot_category_root_select_tag_initial_js
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
    html << "var catArr = #{get_hot_spot_category_js_array(HotSpotCategory.roots).to_json};\n"
    html << "setChildren = function(selectObj,province,defaultValue) {setSelectOption(selectObj, catArr[province], defaultValue);}\n"
    html << "</script>\n"
  end
  
  def hotspot_category_root_select_tag(name, category=nil, include_blank=false, blank_option=['', ''] )
    if category
      if category.level.zero?
        default_value = category.id
      else
        default_value = category.root.id
      end
    else
      default_value = nil
    end
    html = hotspot_category_root_select_tag_initial_js
    html << "<select name='#{name}' onchange=\"if(this.value != '') setChildren(category_children,this.options[this.selectedIndex].value,'#{_('Please select one')}');\">\n"
    options = HotSpotCategory.roots.collect{|cat|  [localized_description(cat, :name),cat.id]}
    options.insert(0, blank_option) if include_blank
    html << options_for_select(options,default_value)
    html << "</select>\n"
  end

  def hotspot_category_children_select_tag(name, category, include_blank=false, blank_option=['', ''] )
    default_value = nil
    categories = nil
    if category
      categories = category.root.all_children
      default_value = category.id unless category.level.zero?
    end
    html = "<select name='#{name}' id='category_children'>\n"
    options = []
    options = categories.collect{|cat|  [hot_spot_category_label_with_level(cat),cat.id]} if categories
    options.insert(0, blank_option) if include_blank
    html << options_for_select(options,default_value)
    html << "</select>\n"
  end
  
  def get_hot_spot_category_js_array(categories)   
     data = Array.new

     categories.each { |category|
       data[category.id] = []
       if category.children
           category.all_children.each { |children|
                 data[category.id].concat([{"txt" => hot_spot_category_label_with_level(children), "val" => children.id}])
           }
       end
     }
     return data
  end
  
  def hot_spot_category_label_with_level(category)
    label = ''
    (category.level * 2).times { label << '-' }
    label << localized_description(category, :name) 
  end    
  
  def hotspot_brand_select_tag(name, include_blank=false, blank_option=[_('Please select one'), '1'])
    html = "<select name='#{name}'>\n"
    options = Brand.find(:all).map{|p| [localized_description(p.name, :name) ,p.id]}
    options.insert(0, blank_option) if include_blank
    html << options_for_select(options)
    html << "</select>\n"
  end
  
  def check_icon(flag)
    image_tag('check.gif') if flag
  end    
  
  def current_is_admin?
    !@current_user.nil? and @current_user.is_admin
  end      
  
  def captcha_code_field(include_comment=true)
    html='<p>'
    html << text_field_tag(:captcha_code, nil, :size=>8)
    html << '</p>'
    if include_comment
      html << '<p class="comment">'
      html << _('Input alphabets and digits shown in following picture. All alphabets are in upper case.')
      html << '</p>'
    end
    html << '<p>'
		html << image_tag('/captcha.jpg', :size=>'140x50', :alt=>'CAPTCHA code', :id=>'img_captcha')
		html << link_to_function(_('Unrecognizable?'), 'refresh_captcha_img()')
		html << '</p>'
  end
  
  def options_for_codes(codes, type=nil, empty_option=nil)
    options = codes.collect { |code| [user_friendly_code(type, code), code ] }
    options.insert(0, empty_option) unless empty_option.nil?
    options
  end
  
  def user_friendly_code(type, code)
    if code.nil? or code.blank?
      ''
    else
      (type.nil? or type.blank?) ? _(code.to_s) : _("#{type}|#{code}")
    end
  end
  
  def page_navigator(collection, link_render=nil, options={})
#    render :partial=>'/page_navigator', :locals => { :pages => pages, :link_render => link_render }
    default_options={:class=>'page_navigator', :previous_label=>_('Previous Page'), :next_label=>_('Next Page'), :inner_window=>4 }
    options = default_options.merge options
    options[:renderer] = link_render if link_render
    will_paginate collection, options
  end
  
  def remote_page_navigator(collection, update=nil, method=nil, options={})
    options = ({:remote=>{:update=>update}, :method=>method || request.method, :params=>params}).merge options
    page_navigator collection, 'RemoteLinkRenderer', options
#      link_render = update.nil? ? lambda { |label, url| link_to_remote label, :url => url, :method=>method } :
#                                  lambda { |label, url| link_to_remote label, :update => update, :url => url, :method=>method }
#      page_navigator(pages, link_render)
  end
  
  def options_for_true_false(selected, include_blank=true)
    options = ([[_('True'), 'true'], [_('False'), 'false']])
    options = [['','']] + options if include_blank
    options_for_select options, selected
  end
  
  def remote_link_render(options)
    options = {:update => options } if options.is_a?(String)
    proc { |label, url| link_to_remote label, options.merge({:url => url}) }
  end
  
  def rss_generator
    "#{XNavi::HOST_NAME} ver.#{XNavi::VERSION}"
  end
  
  def replace_newline(text)
    text.gsub(/$/, '<br/>')
  end
  
  def page_keyword(*keyword)
    if @page_keywords.nil?
      @page_keywords = []
    end
    @page_keywords << keyword
  end
  
  def page_keywords_tag
    unless @page_keywords.nil?
      keywords = @page_keywords.flatten.join(', ')
      return %Q{<META name="keywords" content="#{keywords}">}
    end
  end
  
  def include_js_file(*js_files)
    @js_files = @js_files || []
    @js_files << js_files
  end
  
  def include_css_file(*css_files)
    @css_files = @css_files || []
    @css_files << css_files
  end
  
  def safe_member_logo(member)
    if member.logo
      image_tag member.logo.url
    else
      image_tag 'default_member_logo.jpg', :size=>'96x96'
    end
  end
  
  def member_role(member)
    if member.is_admin
      _('Administrator')
    elsif member.is_merchant
      _('Merchant')
    else
      _('Normal User')
    end
  end
  
  def side_menu(menu)
    @side_menu = menu.to_s
  end
  
  def page_title(title, hide_page_title=false)
    @page_title = title
    @hide_page_title = hide_page_title
  end

  def page_title_tag
    title_token = [@page_title]
    title_token << h(localized_description(@current_city, :name))
    title_token << _('X-Navi')
    return "<title>#{title_token.join('_')}</title>"
  end
  
  def hide_page_title
    @hide_page_title = true
  end
  
  def input_with_help(text,input_id)
    html = '<script language="javascript">'
    html << "input_with_help('#{text}','#{input_id}')"
    html << '</script>'
  end

  def hot_spot_score_stars(score)
    score = score.score if score.is_a?(HotSpot)
    score = (score/25*10)/2
    tmp = []
    (1..score.to_i).each{tmp << image_tag('star.gif')}
    tmp << image_tag('half_star.gif') if score - score.to_i > 0
    (1..(5 - score).to_i).each{tmp << image_tag('empty_star.gif')}
    return tmp
  end

  def hot_spot_score_percent(s,sum_score)
    unless s.blank? || s.zero? || sum_score.blank? || sum_score.zero?
      s = s.to_f
      sum_score = sum_score.to_f
      w = (s / sum_score * 100).to_i
      html = "<span style='border-right:#{w/1.5}px solid #FFB57E;'>&nbsp;</span> #{w.to_i}%"
    end
    return html
  end
  
  def side_menu_for_member(member)
    (member == @current_user) ? 'my_xnavi' : 'member'
  end
    
  def localized_image(source, options={})
    localized_source = File.join XNavi::IMAGE_PATH, @current_lang.to_s, source
    if File.exists?(localized_source)
      image_tag File.join(@current_lang.to_s, source), options
    else
      image_tag source, options
    end
  end
  
  def class_name_for_url(obj)
    clazz = obj.is_a?(Class) ? obj : obj.class
    clazz.to_s.underscore
  end
  
  def class_for_calendar_day(date, month=nil)
    month = Date.today.month if month.nil?
    if date.month == month
      (date.wday == 0) ? 'this_month_sunday' : 'this_month_day'
    else
      (date.wday == 0) ? 'other_month_sunday' : 'other_month_day'
    end
  end
  
  def format_currency(amount)
    return '' if amount.nil?
    return number_to_currency(amount, :unit=>_('$'))
  end

  def blog_root_url(blog)
    "http://#{blog.simple_name}.blog.#{XNavi::SITE_DOMAIN_NAME}"
  end  
  
  def main_menu_class(menu)
    if menu == @selected_menu
      return 'selected_button'
    else
      return 'button'
    end
  end
  
  def select_menu(menu)
    @selected_menu = menu
  end
  
  def use_remote_dialog
    include_js_file 'yui/utilities', 'yui/button', 'yui/container', 'yui/dragdrop', 'remote_form_dialog'
    include_css_file 'yui/button', 'yui/container'
    @use_remote_dialog = true
  end
  
  def show_member_path(member)
    return '' unless member
    if member.blog
      return member.blog.url
    else
      return member_path(member)
    end
  end

  def use_google_map
    @use_google_map = true
  end

  def model_identity(model)
    "#{model.class.to_s.humanize.downcase}_#{model.id}"
  end
end
