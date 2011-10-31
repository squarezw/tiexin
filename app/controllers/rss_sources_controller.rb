class RssSourcesController < ApplicationController
  before_filter :authenticated 
  before_filter :subdomain_find_blog, :only => [:show]
  before_filter :find_or_initialize 
  layout  'default'
  theme :initialize_user_theme  

  helper 'blogs','hot_spots','promotions','brands'
  def initialize_user_theme
    if ['index','show','edit','update','new','info'].include? action_name
      return "standard"
    end
  end
  
  def index
    @rss_sources = @blog.rss_sources
  end
  
  def show
    @rss_source = RssSource.find params[:id]
    @articles = Article.paginate :conditions=> ["member_id = ? and rss_source_id=?",@rss_source.blog.owner.id, @rss_source.id],
                                 :order=>'updated_at desc, created_at desc',
                                 :per_page=>10,
                                 :page=>params[:page]
  end
  
  def new
    
  end
  
  def create
    @rss_source = RssSource.new(params[:rss_source])
    @blog.rss_sources << @rss_source
    @rss_source.retrieve
    @rss_source.save
    flash[:notice] = "'#{@rss_source.title}'已被加入"
    #@rss_source.syndicate!
    redirect_to :action => "index"
  end
  
  def info
    @rss_source = RssSource.new( params[:rss_source] )
    begin
      @rss_source.retrieve
      render :layout=>false
    rescue Exception => e
      render :update do |page|
        page.replace_html 'div_channel_info', "无法取得#{@rss_source.rss}的详细信息，原因：#{e.message}"
      end
    end
  end

  def destroy
    @rss_source = RssSource.find params[:id]
    @rss_source.destroy    
    redirect_to :action => "index"
  end
  
  def syndicate
    RssSource.syndicate_all
    render :update do |page|
     page.alert _('Success')
    end
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
      @blog = params[:blog_id] ? Blog.find(params[:blog_id]) : Blog.new
    end
    find_member
  end
  
  def find_member
    @member = @blog.owner
  end
  
end
