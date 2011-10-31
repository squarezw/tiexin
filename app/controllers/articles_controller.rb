class ArticlesController < ApplicationController
  before_filter :authenticated, :except=>[:index, :show]
  before_filter :find_member
  before_filter :find_folder
  before_filter :find_article, :only=>[:show, :edit, :update, :destroy, :recommend, :cancel_recommend]
  before_filter :find_blog, :only=>[:show, :edit, :new, :create]
  layout 'default'
  
  helper 'comments'
  helper 'brands'
  helper 'hot_spots'
  helper 'blogs'
  helper 'promotions'
  helper 'members'
  helper 'layout_maps'
  
  theme :initialize_user_theme
  
  def initialize_user_theme
	return nil if @mobile_user
    if ['show','new','edit','create'].include? action_name and @member.blog
      return "standard"
    end
  end
  
  def index
    if params.has_key? :city_id
      articles_for_city
      return
    end
    if @folder
      if @folder.blog.member == @current_user
        conditions = ['folder_id = ?', @folder.id, ]
      else
        conditions = ['folder_id = ? and check_status = ?', @folder.id, Article::STATUS_CHECKED]
      end
    else
      if @member == @current_user
        conditions = ['member_id = ?', @member.id ]
      else
        conditions = ['member_id = ? and check_status = ?', @member.id, Article::STATUS_CHECKED]
      end
    end
    @articles = Article.paginate :conditions=>conditions,
                                 :order=>'created_at desc',
                                 :per_page=>10,
                                 :page=>params[:page]
  end
  
  def show
    if @current_user.nil? and @article.check_status != Article::STATUS_CHECKED
      raise ActiveRecord::RecordNotFound
    end
    
    @article.read!
    BlogAccessLog.write_log(@current_user,@blog)
    respond_to do |format|
       format.html{
         unless @article.hot_spots.empty?
            @hot_spot = @article.hot_spots.first
            @city = @hot_spot.city
            logger.info "@city = #{@city}"
            @articles =  @article.hot_spots.first.articles
            @articles = @articles - @article.to_a
          end
       }
       format.xml{
         render :layout=>false
       }       
    end
  end

  def new
    @article = @member.articles.build
    if @folder
      @article.folder = @folder 
      @submit_url = member_folder_articles_path @member, @folder
    else
      @submit_url = member_articles_path @member
    end
    @back_url = request.env['HTTP_REFERER']
  end
  
  def create
    if @folder
      @article = @folder.articles.build params[:article]
      @article.member = @current_user
    else
      @article = @member.articles.build params[:article]
    end
    #@article.check_status = TabooWord.check(@article.content) ? Article::STATUS_CHECKED : Article::STATUS_PENDDING 关键字自动审核
    @article.check_status = @current_user.is_admin or @current_user.has_privilege(:manage_blog) ? Article::STATUS_CHECKED : Article::STATUS_PENDDING
    if params[:pb] and params[:forum_id]
      forum = Forum.find(params[:forum_id])
      if forum
        post = publish_to_bbs(forum)
        if post
          @article.post = post
        else
           flash[:note] = _('Publish to BBS error')
        end
      else
        flash[:note] = _('Can not find forum')
      end
    end
    if @article.save
        if params[:hot_spot_id]
            hot_spot_id = params[:hot_spot_id].split(",").uniq
            hot_spots = HotSpot.find(hot_spot_id)
            for hot_spot in hot_spots
              @article.hot_spots << hot_spot
            end          
        end    
        #flash[:note] = _("Your article including taboo words. Waiting administrator to check manually.") if @article.check_status == Article::STATUS_PENDDING
        flash[:note] = _("Your article published. Waiting administrator to check manually.") if @article.check_status == Article::STATUS_PENDDING
        if @folder
          redirect_to member_folder_path(@member, @folder)
        else
            redirect_to article_path(@article)
        end
    else
      render :action => "new"
    end
  end
  
  def edit
    @hot_spot_ids = @article.id_of_all_hot_spot_article_id.join(',')
    @hot_spot_links = @article.hot_spots.collect {|cat| "'/hot_spots/#{cat.id}'"}.join(',')
    @hot_spot_names = @article.hot_spots.collect {|cat| "'#{localized_description(cat, :name)}'"}.join(',')
  end
  
  def update
    old_folder = @article.folder
    if params[:pb] and params[:forum_id]
       forum = Forum.find(params[:forum_id])
       if forum
          post = publish_to_bbs(forum)
          if post
            @article.post = post
          else
             flash[:note] = _('Publish to BBS error')
          end
       else
          flash[:note] = _('Can not find forum')
       end
    else
      if params[:forum_id] and @article.post
         unless @article.post.forum.id == params[:forum_id]
            unless @article.post.update_attribute(:forum_id , params[:forum_id])
               flash[:note] = _('Publish to BBS error')
            end
         end
      end  
    end
    @article.attributes = params[:article]
    @article.check_status = TabooWord.check(@article.content) ? Article::STATUS_CHECKED : Article::STATUS_PENDDING
    
    if @article.save
       if params[:hot_spot_id]
            hot_spot_id = params[:hot_spot_id].split(",").uniq
            hot_spot_id.collect!{|hot_spot| hot_spot.to_i}
            old_hot_spot_id = @article.id_of_all_hot_spot_article_id            
           
            del_hot_spot_id = old_hot_spot_id - hot_spot_id
            hot_spot_id =  hot_spot_id - old_hot_spot_id if old_hot_spot_id
            
            # delete hot_spots
            if del_hot_spot_id
              hot_spots = @article.hot_spots.find(del_hot_spot_id)
              if hot_spots
                @article.hot_spots.delete(hot_spots)
              end
            end
            
            # add hot_spots
            hot_spots = HotSpot.find(hot_spot_id)
            for hot_spot in hot_spots
              @article.hot_spots << hot_spot
            end
      end
      if @article and old_folder != @article.folder
        old_folder.articles.delete @article
        @article.folder << @article
      end
      flash[:note] = _("Your article including taboo words. Waiting administrator to check manually.") if @article.check_status == Article::STATUS_PENDDING    
      redirect_to article_path(@article)
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @article.destroy
    redirect_to :action => "index"
  end

  def recommend
    if @article.recommend!
      respond_to do |format|
          format.js {
            render :partial => "/articles/article_recommend", :object => @article
          }
      end
    else
      render :layout=>false
    end
  end

  def cancel_recommend
    if @article.cancel_recommend!
      respond_to do |format|
          format.js {
            render :partial => "/articles/article_recommend", :object => @article
          }
      end
    else
      render :layout=>false
    end
  end
  
  private 
  def find_member
    @member = Member.find params[:member_id] if params[:member_id]
  end
  
  def find_folder
    @folder = @member.folders.find params[:folder_id] if @member and params[:folder_id]
  end
  
  def find_article
    if @folder  
      @article = @folder.articles.find params[:id]
    else
      if @member
        @article = @member.articles.find params[:id]
      else
        @article = Article.find params[:id]
      end
    end
	@member = @article.member
  end
  
  def find_blog
    if @member.blog
        @blog = @member.blog
    end
  end
  
  def articles_for_city
    adjust_current_city City.find(params[:city_id])
    @articles = Article.articles_for_city @current_city, :page=>params[:page]
    render :action=>'articles_for_city'
  end
  
  def publish_to_bbs(forum)
      forum = Forum.find(params[:forum_id])
      post = forum.posts.build 
      post.title = params[:article][:subject]
      post.content = "#{params[:article][:summary]}"
      #post.check_status = TabooWord.check(params[:article][:summary]) ? Post::STATUS_CHECKED : Post::STATUS_PENDDING
      post.check_status = @current_user.is_admin or @current_user.has_privilege(:manage_forum) ? Post::STATUS_CHECKED : Post::STATUS_PENDDING # 人工审核
      post.member = @current_user
      if post.save
        return post
      else
        return false        
      end
  end
end
