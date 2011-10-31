require 'imon_exception'
require 'scores'

class PhotosController < ApplicationController
  include XNavi::Score
  
  before_filter :authenticated, :except=>[:index, :show, :random]
  before_filter :find_owner,:except=> [:to_quick_upload, :quick_upload]
  before_filter :find_photo, :only => [:show, :edit, :update, :destroy]                  
  before_filter :modifiable, :only => [:destroy, :edit, :update]
  layout 'default', :only=>[:index, :show]
  
  def index
    @photos = @owner.photos
    respond_to do |format|
      format.html 
      format.xml { render :layout => false }
    end
  end        
  
  def show
  end

  def new         
    @photo = @owner.photos.build()
  end

  def create           
    @photo = @owner.photos.build(params[:photo])
    @photo.uploader = @current_user
    respond_to_parent do
      if @photo.save
        score :upload_photo
        render :layout => false
      else
        render :update  do |page|
          page.replace_html 'form_error', @photo.errors.full_messages.join('<br/>')
          page.call 'dialog.show'
        end
      end
    end
  end

  def edit
  end

  def update  
    unless @photo.update_attributes(params[:photo])
      render :update  do |page|
        page.replace_html 'form_error', @photo.errors.full_messages.join('<br/>')
        page.call 'dialog.show'
      end
    end
  end

  def destroy      
    @photo.destroy
  end            
  
  def random
    @photo = @owner.random_photo
    if @photo
      render :partial=>'photo', :object=>@photo, :locals => {:show_buttons => false}
    else
      render :inline=>%q/<%= image_tag 'nopic.jpg' %>/
    end
  end

  def to_quick_upload
    
  end

  def quick_upload
      @photo = NaviPhoto.new(params[:photo])
      hot_spot = HotSpot.find(:first)
      @photo.owner_type = "HotSpot"
      @photo.owner_id = hot_spot.id
      @photo.uploader = @current_user
      respond_to_parent do
        if @photo.save
          render :update  do |page|
            page.call 'parent.SquareDialog.insert',@photo.photo.big_thumb.url, @photo.subject
          end
        else
          render :update  do |page|
            page.call "top.tinyMCE.activeEditor.windowManager.alert", @photo.errors.full_messages
          end
        end
      end
  end
  
  private
  
  def find_owner
    owner_class = params[:owner_type].camelize.split("::").inject(Object) { |par, const| par.const_get(const) }
    @owner = owner_class.send(:find, params[:owner_id])
  end           
  
  def find_photo
    @photo = @owner.photos.find(params[:id])
  end              
  
  def modifiable
    if @photo.modifiable_to?(@current_user)
      return true
    else
      raise Imon::NoPrivilegeException
    end
  end
end
