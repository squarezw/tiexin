class MemberHotSpotTagsController < ApplicationController
  layout 'default', :except => [:hot_spots_has_tag]
  before_filter :authenticated, :except=>[:index,:show,:hot_spots_has_tag]
  before_filter :find_member
  
  def index
    @hot_spot_tags = HotSpotTag.counts_tags_hotspots(@member.id,1000)
    
    unless @hot_spot_tags.empty?
      if params[:tag]
        @tag = params[:tag]
      else
        @tag =  @hot_spot_tags.first.tag
      end
    end
  end
  
  def show
    @hot_spot_tag = HotSpotTag.find(params[:id])
  end
  
  def edit
    @hot_spot_tag = HotSpotTag.find(params[:id])    
  end
  
  def update
    @hot_spot_tag = HotSpotTag.find(params[:id])
    if @hot_spot_tag.update_attributes(params[:hot_spot_tag])
      flash[:notice] = _('Tag was successfully updated.')
      redirect_to member_posted_tags_path(@member)
    else
      render :action=>'edit'
    end
  end
  
  def destroy
      @hot_spot_tag = HotSpotTag.find(params[:id])
      @hot_spot_tag.destroy
      redirect_to member_posted_tags_path(@member)
  end
  
  def hot_spots_has_tag
    @tag = params[:tag]
    @hot_spot_tags = HotSpotTag.paginate  :conditions => [" tag = ? and member_id = ?",@tag,  params[:member_id]],
                                          :order=>'created_at',
                                          :per_page => 10,
                                          :page=>params[:page]
    unless @hot_spot_tags.empty?
      if params[:tag]
        @tag = params[:tag]
      else
        @tag =  @hot_spot_tags.first.tag
      end
    end    
  end
  
  private
  def find_member
    @member =  Member.find(params[:member_id])
  end 
  
end
