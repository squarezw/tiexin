require 'privilege'

class Admin::BrandsController < ApplicationController
  include XNavi::Privilege 
  before_filter :authenticated, :except=>:check_name
  
  require_privilege :index, :manage_brand
  require_privilege :list, :manage_brand
  require_privilege :new, :manage_brand
  require_privilege :create, :manage_brand
  require_privilege :search, :manage_brand
  require_privilege :merge, :manage_brand
  require_privilege :destroy, :manage_brand
  
  before_filter :is_admin, :except=>[:edit, :update, :remove_hot_spot, :add_hot_spot, :to_add_hot_spot, :destroy]
  before_filter :find_or_initialize_brand, :except => [:index,:remove_hot_spot]
  before_filter :find_brand_for_remove_hot_spot, :only=>[:remove_hot_spot]
  before_filter :check_specially_privilege, :only=>[:edit, :update, :remove_hot_spot, :add_hot_spot, :to_add_hot_spot]

  helper :brands

  layout "admin", :except => [:search_hot_spots,:to_add_hot_spot, :check_name]
  
  auto_complete_for :brand, :name_zh_cn, :limit => 10
  auto_complete_for :member, :nick_name, :limit => 10
  
  def index
    list
    render :action => 'list'
  end

  def list
    @brands = Brand.paginate :order => " id desc",:page => params[:page],:per_page => 10
  end

  def create
    @brand = Brand.new(params[:brand])
    @brand.hot_spot_category = find_hot_spot_category(params[:hot_spot_category_root_id],params[:hot_spot_category_children_id])
    @brand.creator_id = @current_user.id if @current_user
    if @brand.save
      flash[:notice] = _('Brand was successfully created.')
      redirect_to manage_brands_path
    else
      render :action => 'new'
    end
  end
  
  def update
    @brand.hot_spot_category = find_hot_spot_category(params[:hot_spot_category_root_id],params[:hot_spot_category_children_id])
    if @brand.update_attributes(params[:brand])
    flash[:notice] = _('Brand was successfully updated.')
      redirect_to brand_path(@brand)
    else
      render :action=>'edit'
    end
  end

  def destroy
    @brand.destroy
    flash[:note]=_('The brand has been deleted.')
    if @current_user.is_admin?
      redirect_to manage_brands_path      
    else
      redirect_to '/'
    end
  end
  
  def search
    @nick_name = params[:member][:nick_name]
    nick_name = "%#{@nick_name}%"
    member = Member.find(:first,:conditions => ["nick_name like ?",nick_name])
    
    @keyword_exp = params[:brand][:name_zh_cn]
    keyword_exp = "%#{@keyword_exp}%"
    order_cause = "name_#{@current_lang}"
    conditions = ["1=1"]
    unless @keyword_exp.blank?
      conditions.first << " and (name_zh_cn like ? or name_en like ?)"
      conditions << keyword_exp << keyword_exp
    end
    unless @nick_name.blank? and member
      conditions.first << " and creator_id = ?"
      conditions << member.id
    end
    @brands = Brand.paginate :conditions => conditions,
                             :order=> order_cause, :page => params[:page],:per_page => 10
    render :action => "list" 
  end
  
  def merge
    mergeid = params[:checkbox]
    if mergeid
      mfirst = mergeid.first
      mergeid = mergeid[1..mergeid.size]

      HotSpot.update_all(["brand_id=?",mfirst],:brand_id => mergeid)
      Brand.delete(mergeid)
      
      redirect_to edit_manage_brand_path(mfirst)
    else
      redirect_to manage_brands_path
    end
  end
  
  # Search hot spot to add to brand
  def to_add_hot_spot

    @hot_spot_category_id = params[:hot_spot][:hot_spot_category_id] if params[:hot_spot]
    @hot_spot_name = params[:name] || @brand.name[@current_lang]
    
    seach_key = "brand_id is null"
    seach_key << " and hot_spot_category_id = #{@hot_spot_category_id}" if @hot_spot_category_id
    seach_key << " and name_#{@current_lang} like '%#{@hot_spot_name}%'" if @hot_spot_name
    
    @hot_spot = HotSpot.paginate :conditions => seach_key, :page => params[:page] 
    @brand_id = params[:id]
    
    render :layout=>false
  end
  
  def add_hot_spot
    HotSpot.update_all(["brand_id=?",params[:id]],:id => params[:checkbox] )
    redirect_to brand_path(params[:id])
  end
  
  def remove_hot_spot
    @hot_spot =  HotSpot.find(params[:id])
    brand_id = @hot_spot.brand_id
    @hot_spot.update_attribute_with_validation_skipping(:brand_id, "")
    redirect_to brand_path(brand_id)
  end
  
  def check_name
    unless params[:name].nil? or params[:name].strip.empty?
      kw = "%#{params[:name].strip}%"
      brand = Brand.find :first, :conditions=>['name_zh_cn like ? or name_en like ?', kw, kw]
      if brand
        render :text=>_('Thera are already a brand with same name.')
      else
        render :text=>_('There are no brand with same name.')
      end
    else
      render :text=>''
    end
  end
  
  protected
  def find_or_initialize_brand
    @brand = params[:id] ? Brand.find(params[:id]) : Brand.new
# rescue       
#   redirect_to manage_brands_path
  end
  
  def find_brand_for_remove_hot_spot
    @hot_spot = HotSpot.find params[:id]
    @brand = @hot_spot.brand
  end
  
  def check_specially_privilege
    if @current_user == @brand.owner
       return true
    else
       if @current_user.has_privilege :manage_brand
         return true
       end
    end
    alert _('You have no privilege to do this operation.')
  end
end
