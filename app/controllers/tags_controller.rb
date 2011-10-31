class TagsController < ApplicationController
  before_filter :authenticated, :only=>[:new,:create,:destroy]
  before_filter :find_hot_spot, :except => [:show, :destroy]
  layout 'default',:only => [:index,:show, :tag_of_hot_spots]
  
  def index
    @hot_spot_id ||= params[:hot_spot_id]
    @hot_spot_tags = @hot_spot.most_frequent_tags nil
    unless @hot_spot_tags.empty?
      @tag =  @hot_spot_tags.first.tag
    end
    respond_to  do |format|
      format.html
      # TODO: fix bug for hot_spot_id in index.xml.builder
      format.xml { render :layout=>false }
    end 
  end
  
  def new
    @hot_spot_tag = @hot_spot.hot_spot_tags.build
  end
  
  def create
    str = params[:hot_spot_tag][:tag]
    if params[:hot_spot_tag][:description].empty?
      str = str.split(/[ ,]+/)
      str.delete_if {|key| key.blank? }
    end
    
    for tag in str
      HotSpotTag.transaction do 
        params[:hot_spot_tag][:tag] = tag
        @hot_spot_tag = @hot_spot.hot_spot_tags.build(params[:hot_spot_tag])
        @hot_spot_tag.member = @current_user      
        unless @hot_spot_tag.save
          logger.info "#{@hot_spot_tag}"
          render :update do |page|
            page.replace_html 'tag_form_error', @hot_spot_tag.errors.full_messages.join("\n")
            page.call 'dialog.show'
          end
          return
        end
      end
    end
  end
  
  def show
    tag = HotSpotTag.find params[:id]
    @tags = HotSpotTag.paginate :conditions => ['tag = ? and id <> ?', tag.tag, params[:id]],
                                :per_page => 20,
                                :order=>'id',
                                :page=>params[:page]
  end

  def destroy
    @hot_spot_tag = HotSpotTag.find params[:id]
    if @hot_spot_tag.modifiable_to?(@current_user)
      @hot_spot_tag.destroy
      render :update do |page|
        page.remove element_id(@hot_spot_tag)
      end
    else
      raise Imon::NoPrivilegeException
    end
  end

  def tag_description
    @tag ||= params[:tag]
    respond_to do |format|
      format.html {
          per_page = (params[:template] == 'panel') ? 5 : 20
          @hot_spot_tags = HotSpotTag.paginate :per_page => per_page, 
                              :conditions =>["tag = ? and hot_spot_id = ?",@tag, @hot_spot.id], 
                              :order=>'created_at', 
                              :page=>params[:page]
          if params[:template] == 'panel'
            render  :action => "tag_description_panel"
          end
      }
      
      format.xml {
        @hot_spot_tags = HotSpotTag.find :all, :conditions =>["tag = ? and hot_spot_id = ?",@tag, @hot_spot.id], :order=>'created_at'
        render :layout=>false
      }
    end
  end
  
  # side hot spots of tag
  def tag_hot_spots
    @hot_spots = HotSpot.paginate :select => 'hot_spots.*',
                                  :include => :hot_spot_tags,
                                  :conditions => ['hot_spot_tags.tag = ? and hot_spots.city_id = ? and hot_spots.id <> ?', params[:tag], @hot_spot.city_id, @hot_spot.id],
                                  :per_page => 20,
                                  :order=>"hot_spots.name_#{@current_lang}",
                                  :page=>params[:page]
    unless @hot_spots.empty?
      @tag =  params[:tag] if params[:tag]
    end
  end
  
  private
  def find_hot_spot
    @hot_spot = HotSpot.find(params[:hot_spot_id])
    adjust_current_city @hot_spot.city
  end
end
