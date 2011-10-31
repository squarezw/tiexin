require 'scores'
require 'privilege'

class Admin::HotSpotsController < ApplicationController
  include XNavi::Score
  include XNavi::Privilege
  
  before_filter :authenticated
  before_filter :is_admin, :except=>:destroy
  
  require_privilege :destroy, :modify_hot_spot
  require_privilege :approve, :approve_hot_spot
  require_privilege :waiting_approve, :approve_hot_spot
  layout 'default'

  auto_complete_for :member, :nick_name, :limit => 10
  auto_complete_for :brand, :name_zh_cn, :limit => 10
  auto_complete_for :hot_spot_tag, :tag, :limit => 10
  
  def index
  end

  def destroy
    @hot_spot = HotSpot.find(params[:id])
    @hot_spot.destroy
  end
  
  def approve
    ids = params[:id]
    @hot_spots = HotSpot.find(ids)
    HotSpot.transaction do
      if @hot_spots.is_a?(Array)
        for hot_spot in @hot_spots
          score :hot_spot_approved, hot_spot.creator
          hot_spot.update_attribute_with_validation_skipping(:approved, true)
        end
      else
          score :hot_spot_approved, @hot_spots.creator
          @hot_spots.update_attribute_with_validation_skipping(:approved, true)
      end
      if request.request_uri.include?"hot_spots/approve"
        #params.delete(:page)
        params.merge!(:controller=>'admin/hot_spots', :action=>'waiting_approve')
        @reurl = params
      else
        @reurl = @hot_spots
      end
    end
    redirect_to @reurl
  end                            
  
  def waiting_approve
    @cities = City.find(:all, :select=>"id,name_#{@current_lang}").collect{|p| [localized_description(p, :name),p.id]}
    conditions = ["approved = 0"]
    unless params[:city].nil? || params[:city][:id].blank?
      @city_select = params[:city][:id].to_i
      conditions.first << " and city_id = ?"
      conditions << @city_select
    end
    unless params[:hot_spot_category].nil? || params[:hot_spot_category][:hot_spot_category_id].blank?
      @hot_spot_category_select = params[:hot_spot_category][:hot_spot_category_id].to_i
      conditions.first << " and hot_spot_category_id in (?)"
      conditions << HotSpotCategory.find(@hot_spot_category_select).id_of_all_children_include_self
    end
    unless params[:name].nil? || params[:name].blank? 
      keyword = "%#{params[:name]}%"
      conditions.first << " and (name_en like ? or name_zh_cn like ?)"
      conditions << keyword
      conditions << keyword
    end
    unless params[:member].nil? || params[:member][:nick_name].blank?
      conditions.first << " and creator_id = (select id from members where nick_name = ?)"
      conditions << params[:member][:nick_name]
      @member_select = params[:member][:nick_name]
    end
    unless params[:begin_date].blank?
      conditions.first << " and created_at > ?"
      conditions << params[:begin_date]
    end
    unless params[:end_date].blank?
      conditions.first << " and created_at < ?"
      conditions << params[:end_date]
    end
    @hot_spots = HotSpot.paginate :conditions=>conditions, :order => "created_at", :per_page=>20, :page=>params[:page]
  end
  
  def recommend
    ids = params[:id].split(',').collect!{|x|x.to_i}
    @hot_spots = HotSpot.find(ids)
    for hot_spot in @hot_spots
      hot_spot.recommended(1)
    end
    if request.xhr?
       render :update do |page|
          page.alert _("hot spot successfully recommend")
        end
    else
        redirect_to waiting_recommend_manage_hot_spots_path
    end
  end
 
  def cancel_recommend
    ids = params[:id].split(',').collect!{|x|x.to_i}
    @hot_spots = HotSpot.find(ids)
    for hot_spot in @hot_spots
      hot_spot.cancel_recommended
    end
    respond_to do |format|
      format.js {
        render :update do |page|
          page.alert _("hot spot successfully cancel recommend")
        end
      }
      format.html{
        redirect_to waiting_recommend_manage_hot_spots_path
      }
    end
  end

  def recommend_ontop
    @hot_spot = HotSpot.find(params[:id])
    @hot_spot.recommended_ontop(1)
    if request.xhr?
        render :layout => false
    else
        redirect_to waiting_recommend_manage_hot_spots_path
    end
  end

  def cancel_recommend_ontop
    hot_spot = HotSpot.find(params[:id])
    hot_spot.cancel_recommended_ontop
    redirect_to waiting_recommend_manage_hot_spots_path
  end
  
  def waiting_recommend
    @cities = City.find(:all, :select=>"id,name_#{@current_lang}").collect{|p| [localized_description(p, :name),p.id]}
    conditions = ["1=1"]
    unless params[:city].nil? || params[:city][:id].blank?
      @city_select = params[:city][:id].to_i
      conditions.first << " and city_id = ?"
      conditions << @city_select
    end
    unless params[:hot_spot_category].nil? || params[:hot_spot_category][:hot_spot_category_id].blank?
      @hot_spot_category_select = params[:hot_spot_category][:hot_spot_category_id].to_i
      conditions.first << " and hot_spot_category_id in (?)"
      conditions << HotSpotCategory.find(@hot_spot_category_select).id_of_all_children_include_self
    end
    unless params[:name].nil? || params[:name].blank? 
      keyword = "%#{params[:name]}%"
      conditions.first << " and (name_en like ? or name_zh_cn like ?)"
      conditions << keyword
      conditions << keyword
    end
    unless params[:address].nil? || params[:address].blank? 
      keyword = "%#{params[:address]}%"
      conditions.first << " and (address_en like ? or address_zh_cn like ?)"
      conditions << keyword
      conditions << keyword
    end
    unless params[:is_owner].nil? || params[:is_owner].blank? 
      if params[:is_owner] =~ /(yes)|(true)/i
        conditions.first << " and owner_id is not null"        
      else
        conditions.first << " and owner_id is null"
      end        
    end
    unless params[:recommend_expire_at].nil? || params[:recommend_expire_at].blank? 
      conditions.first << " and recommend_expire_at <= ? "
      conditions << params[:recommend_expire_at].to_time
    end
    if conditions == ["1=1"]
        conditions = ["recommend is true"]
    end
    @hot_spots = HotSpot.paginate :conditions=>conditions, :order => "recommend desc, recommend_expire_at", :per_page=>20, :page=>params[:page]
  end
  
  def recommend_for_brand
    unless params[:brand].nil? || params[:brand][:name_zh_cn].blank?
      brand = Brand.find_by_name_zh_cn(params[:brand][:name_zh_cn])
      if brand
        brand.recommend_for_brand(1)
        flash[:note] = _('Hot Spots of brand %{brand} have been recommended.') % {:brand=>localized_description(brand, :name)}
      else
        flash[:note] = _('Can not find brand')
      end      
    else
      flash[:note] = _('Brand name is blank.')
    end    
    redirect_to waiting_recommend_for_brand_manage_hot_spots_path
  end
  
  def recommend_for_tag
    unless params[:hot_spot_tag].nil? || params[:hot_spot_tag][:tag].blank?
      tag = HotSpotTag.find_by_tag(params[:hot_spot_tag][:tag])
      unless tag.nil? || tag.blank?
        HotSpotTag.recommend_for_tag(params[:hot_spot_tag][:tag],1)
        flash[:note] = _('Hot Spots with tag %{tag} have been recommended.') % {:tag=> params[:hot_spot_tag][:tag]}
      else
        flash[:note] = _('Can not find tag')
      end
    else
      flash[:note] = _('Tag is blank.')
    end
    redirect_to waiting_recommend_for_tag_manage_hot_spots_path
  end
  
end
