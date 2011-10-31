class PicturesController < ApplicationController
  before_filter :authenticated, :except=> [:show, :index]
  before_filter :subdomain_find_blog
  before_filter :find_or_initialize
  before_filter :is_author, :except=> [:show, :index]
  
  layout  'default', :only=>[:index, :show, :edit, :update]
  theme :initialize_user_theme  

  helper 'blogs'
  helper 'hot_spots'
  helper 'promotions'
  helper 'brands'
  helper 'photos'
  
  def initialize_user_theme
    if ['show','new','edit','update','index','create'].include? action_name
      return "standard"
    end
  end
  
  def index
    @pictures = @member.pictures
    @photos = NaviPhoto.paginate_by_uploader_id @member.id,
                               :order => 'created_at',
                               :page=>params[:page]
    BlogAccessLog.write_log(@current_user,@blog)
  end
  
  def new

  end
  
  def create
    params[:picture][:name] = nil if params[:picture][:name] and params[:picture][:name].blank?
    params[:picture][:tag_list] = nil if params[:picture][:tag_list] and params[:picture][:tag_list].blank?
    @picture.attributes = params[:picture]
    @picture.member = @member
    if @picture.save                  
      respond_to_parent do
        render :layout => false
      end
    else                          
      respond_to_parent do
        render :update do |page|
          page.replace_html 'form_error', @picture.errors.full_messages.join("<br/>")
          page.call 'dialog.show'
        end
      end
    end
  end
  
  def edit
    
  end

  def update
    params[:picture][:name] = nil if params[:picture][:name] and params[:picture][:name].blank?
    params[:picture][:tag_list] = nil if params[:picture][:tag_list] and params[:picture][:tag_list].blank?
    if @picture.update_attributes(params[:picture])
      redirect_to blog_pictures_path(@blog)      
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @picture.destroy
    redirect_to blog_pictures_path(@blog)
  end
  
  def show

  end
  private 
  
  def is_author
    unless @member == @current_user
      redirect_to new_session_path
      return false      
    end
  end

  def subdomain_find_blog
     if request.subdomains.is_a? Array and !request.subdomains.empty?
      if request.subdomains[1] == "blog"
        @blog = Blog.find_by_simple_name(request.subdomains.first.to_s)
        if @blog.nil?
          redirect_to "http://#{XNavi::DOMAIN_NAME}"
        end
      end
     end
  end
  
  def find_or_initialize
    find_blog
    find_member
    @picture = params[:id] ? Picture.find(params[:id]) : Picture.new
  end

  def find_blog
    if @blog.nil? and params[:blog_id]
      @blog = Blog.find(params[:blog_id])
    end
  end
  
  def find_member
    unless @blog.nil?
      @member = @blog.owner
    else
      if params[:member_id]
          @member = Member.find(params[:member_id])
      end
    end
  end
  
end
