require 'dynamic_query'
class BlogsController < ApplicationController
  include Imon::DynamicQuery
  before_filter :authenticated, :only=>[:new,:create,:update,:edit]
  before_filter :subdomain_find_blog, :only => [:show, :about]
  before_filter :find_or_initialize, :except => [:index] 
  before_filter :find_folder, :only => [:show]
  
  layout  'default'
  theme :initialize_user_theme
  helper 'hot_spots','promotions', 'brands'

  def initialize_user_theme
    if ['show','article','edit','update','about'].include? action_name
      return "standard"
    end
  end
  
  def index
    @articles = Article.paginate :conditions=>['check_status = ?', Article::STATUS_CHECKED], :page=>params[:page], :per_page=>10, :order=>'created_at desc'
  end

  def new
    
  end
  
  def create
    @blog = Blog.new(params[:blog])
    @blog.owner = @current_user
    if @blog.save
      flash[:notice] = _('Blog was successfully created.')
      redirect_to blog_path(@blog)
    else
      render :action => 'new'
    end
  end
  
  def edit
    
  end
  
  def update
    params[:blog][:name] = nil if params[:blog][:name] and params[:blog][:name].blank?
    if @blog.update_attributes(params[:blog])
      flash[:notice] = _('Blog was successfully updated.')
    end
    render :action=>'edit'
  end
  
  def show
    @blog.read!
    BlogAccessLog.write_log(@current_user,@blog)
    if params.has_key? :city_id
      articles_for_city
      return
    end

    exps = []
    if @folder
      exps << self.equal(:folder_id, @folder.id)
    else
      exps << self.equal(:member_id, @member.id)
    end
    
    exps << self.equal(:check_status, Article::STATUS_CHECKED) unless @member == @current_user
    exps << self.like(:subject, params[:q]) if params[:q]

    @articles = Article.paginate :conditions=>self.and(exps).conditions,
                                 :order=>'created_at desc',
                                 :per_page=>10,
                                 :page=>params[:page]
    
    respond_to do |format|      
       format.html
       format.rss do
         render :partial => "rss20_feed", :object => @articles
       end
    end    
  end
  
  def about
      BlogAccessLog.write_log(@current_user,@blog)
  end

  private 
  
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
    if @blog.nil?
      @blog = params[:id] ? Blog.find(params[:id]) : Blog.new
    end
    find_member
  end

  def find_member
    @member = @blog.owner
  end
  
  def find_folder
    @folder = @member.folders.find params[:folder_id] if @member and params[:folder_id]
  end

end
