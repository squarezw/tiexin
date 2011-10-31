require 'dynamic_query'
require 'privilege'

class HotSpotsController < ApplicationController     
  include Imon::DynamicQuery
  include XNavi::Privilege

#  before_filter :detect_robot, :only=>[:show]
  before_filter :authenticated, :only=>[:new, :create, :edit, :update, :move, :send_email, :to_recommend, :recommend]
  require_privilege :move, :modify_hot_spot
    
  helper 'products' 
  helper 'photos'
  helper 'admin/hot_spot_categories' 
  helper 'positions'  
  helper 'comments'  
  helper 'layout_maps'  
  helper 'map_blocks'
  helper 'admin/owner_applications'
  helper 'brands'
  helper 'promotions'
  helper 'hot_spot_categories'
  helper 'scores'
  helper 'events'
  helper 'members'
  
  layout 'default', :only => ['show', 'gmap']

  auto_complete_for :brand, :name_zh_cn, :limit => 10
  auto_complete_for :brand, :name_en, :limit=>10
    
  def show
    @hot_spot = HotSpot.find(params[:id])
    adjust_current_city @hot_spot.city
    write_hot_spot_access_log
    respond_to  do |format|
      format.html
      format.xml { render :layout=>false }
    end 
  end
  
  def detail
    redirect_to :action => "show"
  end

  def new             
    adjust_current_city City.find(params[:city_id])
    @hot_spot = @current_city.hot_spots.build(:x=>params[:x], :y=>params[:y])
  end  
  
  def marker
    @hot_spot = HotSpot.find(params[:id])
    @no_bubble = (params[:bubble] and (params[:bubble] == '0' or params[:bubble].downcase == 'false'))
  end
  
  def create                
    @hot_spot = create_hot_spot(params)
    unless @hot_spot.save     
      respond_to do |format|
        format.js {
          render :update do |page|
            page.replace_html 'form_error', @hot_spot.errors.full_messages.join("<br/>")
            page.call 'dialog.show'
          end
        }
        
        format.xml {
          @errors = @hot_spot.errors
          render :template=>'/active_record_error', :layout=>false
        }
      end     
    else
      if @hot_spot.brand and @hot_spot.brand.hot_spot_category_id.nil?
        @hot_spot.brand.update_attribute(:hot_spot_category_id, @hot_spot.hot_spot_category_id)
      end
      respond_to do |format|
        format.js { render :layout=>false }
        format.xml { render :layout=>false }
      end
    end
  end
  
  def edit                                  
    @hot_spot = HotSpot.find(params[:id])        
    raise Imon::NoPrivilegeException unless @hot_spot.modifiable_to(@current_user)
  end
  
  def update
    @hot_spot = HotSpot.find(params[:id])
    @hot_spot.hot_spot_category = find_hot_spot_category(params[:hot_spot_category_root_id],params[:hot_spot_category_children_id])
    unless @hot_spot.update_attributes(params[:hot_spot])
      render :action=>'form_error'
    end
  end  
  
  def refresh_tree_node_and_marker
    @hot_spot = HotSpot.find(params[:id])
  end         
  
  def show_marker_info
    @hot_spot = HotSpot.find(params[:id])
  end     
  
  def move
    @hot_spot = HotSpot.find(params[:id])
    @hot_spot.update_attributes(:x=>params[:x], :y=>params[:y])
    render :nothing => true
  end    
  
  def access_traffic_lines
    @hot_spot = HotSpot.find(params[:id])
    respond_to  do |format|
      format.html
      format.xml { 
        @traffic_lines = @hot_spot.access_traffic_lines
        render :template => "traffic_lines/index.rxml", :layout=>false }
    end
  end
  
  def edit_brand
    @hot_spot = HotSpot.find(params[:id])
    @brandname = @hot_spot.brand ? @hot_spot.brand.name[@current_lang] : ""
  end
  
  def update_brand
    @hot_spot =  HotSpot.find(params[:id])
    attr_name = "name_#{@current_lang}"
    brand_name = params[:brand][attr_name]
   
    unless brand_name.nil? or brand_name.blank?
      brand = find_brandname(brand_name,@hot_spot)
      unless brand.errors.empty?
        render :update do |page|
             page.replace_html 'error_msgs', brand.errors.full_messages.join ('<br/>')
             page.show 'error_msgs'
             page.call 'dialog.show'
       end
      else # There are error when save brand.
        if @hot_spot
          @hot_spot.update_attribute_with_validation_skipping(:brand_id, brand.id)
          if brand.hot_spot_category_id.nil?
             brand.update_attribute(:hot_spot_category_id, @hot_spot.hot_spot_category_id)
          end
        end
      end
    end     
  end

  def articles
    @hot_spot = HotSpot.find params[:id]
    respond_to do |format|
       format.html {
        @articles = Article.articles_for_hot_spot @hot_spot,
                                      :page => params[:page]         
          render :partial=> 'articles/article_list', :layout=>false
       }
       format.xml{
         parse_start_limit
        @articles = Article.articles_for_hot_spot @hot_spot,
                    :page=> @page, :per_page=>@per_page
        render :template=> 'articles/article_list', :layout=>false
      }
     end
  end
  
  def products
    @hot_spot = HotSpot.find params[:id]
    @products = @hot_spot.products_include_brands :order=>"name_#{current_lang}", :per_page=>4, :page=>params[:page]
  end
  
  def to_recommend
    @hot_spot = HotSpot.find params[:id]
    @from = params[:from] || @current_user.nick_name
    @receiver = params[:receiver] || ''
  end
  
  def recommend
    @hot_spot = HotSpot.find params[:id]
    errors = []
    partial_sent = false
    if params[:receiver].nil? or params[:receiver].empty?
      errors << _('You must input at least one email address')
    end
    if params[:from].nil? or params[:from].empty?
      errors << _(%q/'Recommender' is required./)
    end
    @error_emails = []
    sent_members = []
    if errors.empty?
      params[:receiver].strip.sub('，', ',').split(/\s*,\s*/).uniq.each do |receiver|
        logger.info "sent_members=#{sent_members}"
        if receiver =~ /(.*)@.*/
          member = recommend_to_email @hot_spot, receiver, $1, params[:from], params[:note], sent_members
          partial_sent = true
        else
          member = Member.find_by_nick_name receiver
          unless member.nil? or !member.confirmed
            logger.info "member=#{member}"
            logger.info "sent_members.include?=#{sent_members.include?(member)}"
            unless sent_members.include? member
              recommend_to_member @hot_spot, member, params[:from], params[:note]
              sent_members << member
              partial_sent = true
            end
          else
            @error_emails << receiver
            errors << _(%q(%{email} is not a valid email address or a member's login name , ignore it.)) % { :email=>receiver }
          end
        end
      end
    end
  
    
    respond_to do |format|
        format.html {
          if errors.empty?
            render :update do |page|
              page.alert _('Email has been sent.')
            end
          else
            render :update do |page|
              receiver = partial_sent ? @error_emails.join (',') : params[:receiver]
              page.replace_html 'error_msgs', errors.join ('<br/>')
              page.show 'error_msgs'
              page << "$('receiver').value='#{receiver}';"
                      page.call 'dialog.show_with_title', _('Send email to friends to recommend this hot spot.')
            end
          end
        }
        format.xml {
          if errors.empty?
             render :layout=>false
          else
             @error_message = errors
             render :template => "hot_spots/recommend_error.rxml", :layout=>false 
          end
        }         
      end

  end
  
  def basic_information
    @hot_spot = HotSpot.find(params[:id])
    render :partial => "basic_information",:locals=> {:hot_spot => @hot_spot}, :layout => false
  end
  
  def capabilities
    @hot_spot = HotSpot.find params[:id]
    @capabilities = @hot_spot.capabilities
  end
  
  def brand
    @hot_spot = HotSpot.find params[:id]
    if @hot_spot and @hot_spot.brand
      @brand = @hot_spot.brand
    else
      error_xml(201) 
    end
  end
  
  protected
  def create_hot_spot(params)
    hot_spot=HotSpot.new(params[:hot_spot])
    cat_id = params[:hot_spot][:hot_spot_category_id]
    unless cat_id.nil?
      hot_spot.hot_spot_category = HotSpotCategory.find cat_id
    else
      hot_spot.hot_spot_category = find_hot_spot_category params[:hot_spot_category_root_id],
                                                          params[:hot_spot_category_children_id]
    end
    hot_spot.city=@current_city unless hot_spot.city
    hot_spot.creator = current_user
    hot_spot.name[@current_lang] = params[:name]
    hot_spot.address[@current_lang] = params[:address]
    hot_spot.introduction[@current_lang] = params[:introduction]  
    hot_spot.operation_time[@current_lang] = params[:operation_time]

    attr_name = "name_#{@current_lang}"
    brand_name = params[:brand][attr_name] if params[:brand]

    unless brand_name.nil? or brand_name.blank?
      brand = find_brandname(brand_name,hot_spot)
      unless brand.errors.empty?
        render :update do |page|
           page.replace_html 'form_error', brand.errors.full_messages.join("\n")
           page.call 'dialog.show'
       end
      else # There are error when save brand.
        hot_spot.brand_id = brand.id
      end
    end
    
    return hot_spot
  end
  
  def find_brandname(keyword_exp,hot_spot = nil)
      order_cause = "name_#{@current_lang}"
      brand =  Brand.find(:first,:conditions => ['name_zh_cn = ? or name_en = ?', keyword_exp, keyword_exp],:order=> order_cause)
      unless brand.nil?
        return brand
      else
        brand = Brand.new
        brand.creator_id = @current_user.id if @current_user
        brand.name[@current_lang] = keyword_exp
        brand.hot_spot_category = hot_spot.hot_spot_category if hot_spot
        brand.save
        return brand
      end      
  end

  def search_area
    kw = "%#{params[:area]}%"
    @areas = @current_city.areas.find(:all, :conditions => ['name_zh_cn like ? or name_en like ?', kw, kw],
      :offset=>@start, :limit => @limit, :order=>"name_#{@current_lang}")
    render :action=>'search_area', :layout=>false
  end
  
  def write_hot_spot_access_log
    HotSpotAccessLog.create (:member=>@current_user, :hot_spot=>@hot_spot, :from_mobile=>@mobile_user || false) unless NaviAccessLog.from_robot?(request.env['HTTP_USER_AGENT'])
  end
  
  private
  def recommend_to_member(hot_spot, member, from, note)
    lang = member.favorite_lang || 'zh_cn'
    hot_spot_name = 
    member.recommend_hot_spot_by_friend hot_spot, @current_user
    member.receive_message @current_user, 
      'Recommend hot spot',
      %q('%{from}' recommend hot spot '%{hot_spot_name}' to you. You can click [url=%{url}]here[/url] for detail information. His additional note to you: %{note}),
      {:from=>from, :url=>hot_spot_path(hot_spot), :hot_spot_name=>hot_spot.name.safe_value_for_lang(lang), :note=>note}
    HotSpotsMailer.deliver_recommend hot_spot, from, member.nick_name, member.mail, note unless member.mail.nil? or member.mail.empty? 
  end

  N_('Recommend hot spot')
  N_(%q('%{from}' recommend hot spot '%{hot_spot_name}' to you. You can click [url=%{url}]here[/url] for detail information. His additional note to you: %{note}))
  
  def recommend_to_email(hot_spot, mail_address, receiver_name, from, note, sent_members)
    member = Member.find_by_mail mail_address
    return if sent_members.include? member
    if member.nil?
      HotSpotsMailer.deliver_recommend hot_spot, from, receiver_name, mail_address, note
    elsif member.mail
      recommend_to_member hot_spot, member, from, note
    end
    sent_members << member
  end
end
