class Admin::TopicsController < ApplicationController
  before_filter :authenticated
  before_filter :is_admin
  
  layout 'default'
  
  helper 'hot_spots','hot_spot_categories'
  helper 'photos'
  
  auto_complete_for :hot_spot, :name_zh_cn, :limit => 10
  
  def index
    @topics = Topic.paginate :order=>'updated_at desc, created_at desc',
                                 :per_page=>20,
                                 :page=>params[:page]
  end
  
  def new
    @topic = Topic.new
    @cities = City.find(:all, :select=>"id,name_#{@current_lang}").collect{|p| [localized_description(p, :name),p.id]}
  end
  
  def create
    @topic = Topic.new params[:topic]
    if @topic.save
        if params[:article_id]
            article_id = params[:article_id].split(",").uniq
            articles = Article.find(article_id)
            for article in articles
              @topic.articles << article
            end
        end
        if params[:post_id]
            post_id = params[:post_id].split(",").uniq
            posts = Post.find(post_id)
            for post in posts
              @topic.posts << post
            end
        end
        if params[:hot_spot_id]
            hot_spot_id = params[:hot_spot_id].split(",").uniq
            hot_spots = HotSpot.find(hot_spot_id)
            for hot_spot in hot_spots
              @topic.hot_spots << hot_spot
            end
        end        
        redirect_to :action => "index"
    else
      render :action => "new"
    end
  end

  def edit
    @cities = City.find(:all, :select=>"id,name_#{@current_lang}").collect{|p| [localized_description(p, :name),p.id]}
    @topic = Topic.find params[:id]
    @topic.expire_date = @topic.expire_date.to_date if @topic.expire_date
    @article_ids = @topic.id_of_all_article_topic_id.join(',')
    @article_links = @topic.articles.collect {|cat| "'/articles/#{cat.id}'"}.join(',')
    @article_names = @topic.articles.collect {|cat| "'#{cat.subject}'"}.join(',')

    @post_ids = @topic.id_of_all_post_topic_id.join(',')
    @post_links = @topic.posts.collect {|cat| "'/articles/#{cat.id}'"}.join(',')
    @post_names = @topic.posts.collect {|cat| "'#{cat.title}'"}.join(',')

    @hot_spot_ids = @topic.id_of_all_hot_spot_topic_id.join(',')
    @hot_spot_links = @topic.hot_spots.collect {|cat| "'/articles/#{cat.id}'"}.join(',')
    @hot_spot_names = @topic.hot_spots.collect {|cat| "'#{localized_description(cat, :name)}'"}.join(',')        
  end
  
  def update
    @topic = Topic.find params[:id]
    if params[:type] == "expo"
      params[:topic_expo][:travel_line_family] = params[:topic_expo][:travel_line_family].values.join(",") if params[:topic_expo][:travel_line_family]
      params[:topic_expo][:travel_line_sweet] = params[:topic_expo][:travel_line_sweet].values.join(",") if params[:topic_expo][:travel_line_sweet]
      params[:topic_expo][:travel_line_grandparent] = params[:topic_expo][:travel_line_grandparent].values.join(",") if params[:topic_expo][:travel_line_grandparent]
      params[:topic_expo][:travel_line_child] = params[:topic_expo][:travel_line_child].values.join(",") if params[:topic_expo][:travel_line_child]
      @topic_expo = @topic.topic_expo
      if @topic_expo
        @topic_expo.update_attributes params[:topic_expo]
      else
        @topic_expo = TopicExpo.new(params[:topic_expo])
        @topic.topic_expo = @topic_expo
      end
    end
    if @topic.update_attributes params[:topic]
       if params[:article_id]
          article_id = params[:article_id].split(",").uniq      
          #article_id.collect!{|article| article.to_i}
          old_article_id = @topic.id_of_all_article_topic_id
          del_article_id = old_article_id - article_id
          article_id =  article_id - old_article_id if old_article_id

          # delete articles
          if del_article_id
            articles = @topic.articles.find(del_article_id)
            if articles
              @topic.articles.delete(articles)
            end
          end

          # add articles
          articles = Article.find(article_id)
          for article in articles
            @topic.articles << article
          end
      end
      
      if params[:post_id]
          post_id = params[:post_id].split(",").uniq      
          old_post_id = @topic.id_of_all_post_topic_id
          del_post_id = old_post_id - post_id
          post_id =  post_id - old_post_id if old_post_id

          # delete posts
          if del_post_id
            posts = @topic.posts.find(del_post_id)
            if posts
              @topic.posts.delete(posts)
            end
          end

          # add posts
          posts = Post.find(post_id)
          for post in posts
            @topic.posts << post
          end
      end

      if params[:hot_spot_id]
          hot_spot_id = params[:hot_spot_id].split(",").uniq      
          old_hot_spot_id = @topic.id_of_all_hot_spot_topic_id
          del_hot_spot_id = old_hot_spot_id - hot_spot_id
          hot_spot_id =  hot_spot_id - old_hot_spot_id if old_hot_spot_id

          # delete hot_spots
          if del_hot_spot_id
            hot_spots = @topic.hot_spots.find(del_hot_spot_id)
            if hot_spots
              @topic.hot_spots.delete(hot_spots)
            end
          end

          # add hot_spots
          hot_spots = HotSpot.find(hot_spot_id)
          for hot_spot in hot_spots
            @topic.hot_spots << hot_spot
          end
      end      
      redirect_to :action => "index"
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @topic = Topic.find params[:id]
    @topic.destroy
    redirect_to :action => "index"
  end
  
  def related_articles
    conditions = []
    @articles = Article.paginate :conditions=>conditions,
                                 :order=>'id desc',
                                 :per_page=>10,
                                 :page=>params[:page]
    render :layout=>false
  end
  
  def related_posts
    conditions = []
    @posts = Post.paginate :conditions=>conditions,
                                 :order=>'id desc',
                                 :per_page=>10,
                                 :page=>params[:page]
    render :layout=>false
  end
  
  def related_hot_spots
    conditions = []
    if params[:hot_spot] and params[:hot_spot][:name_zh_cn]
      name_zh_cn = params[:hot_spot][:name_zh_cn]
      conditions = ["name_zh_cn like ?", "%#{name_zh_cn}%"]
      @keyword_exp = name_zh_cn
    end
    @hot_spots = HotSpot.paginate :conditions=>conditions,
                                 :order=>'updated_at desc, created_at desc',
                                 :per_page=>10,
                                 :page=>params[:page]
    render :layout=>false
    
  end
  
  def publish
    topic = Topic.find params[:id]
    subscription_topic = SubscriptionTopic.find_or_create_by_name :topic
    subscription_topic.subscription_messages.create! :content_object=>topic, :sent=>false
    flash[:note] = _('Email will be sent to all members to inform this topic.')
    redirect_to :action => "index"
  end

  def expo
    @topic = Topic.find_by_title("世博专题")
    @cities = City.find(:all, :select=>"id,name_#{@current_lang}").collect{|p| [localized_description(p, :name),p.id]}
    if @topic
      @surl = admin_topic_path(@topic)
      @method = "put"
      
      @topic_expo = @topic.topic_expo
      @recommend_hot_spots_family = HotSpot.find(@topic_expo.square_ids_family.split(",")) if @topic_expo and @topic_expo.square_ids_family
      @recommend_hot_spots_sweet = HotSpot.find(@topic_expo.square_ids_sweet.split(",")) if @topic_expo and @topic_expo.square_ids_sweet
      @recommend_hot_spots_grandparent = HotSpot.find(@topic_expo.square_ids_grandparent.split(",")) if @topic_expo and @topic_expo.square_ids_grandparent
      @recommend_hot_spots_child = HotSpot.find(@topic_expo.square_ids_child.split(",")) if @topic_expo and @topic_expo.square_ids_child
      @food_hot_spots = HotSpot.find(@topic_expo.food_ids.split(",")) if @topic_expo and @topic_expo.food_ids

      @topic.expire_date = @topic.expire_date.to_date if @topic.expire_date
      @article_ids = @topic.id_of_all_article_topic_id.join(',')
      @article_links = @topic.articles.collect {|cat| "'/articles/#{cat.id}'"}.join(',')
      @article_names = @topic.articles.collect {|cat| "'#{cat.subject}'"}.join(',')

      @post_ids = @topic.id_of_all_post_topic_id.join(',')
      @post_links = @topic.posts.collect {|cat| "'/articles/#{cat.id}'"}.join(',')
      @post_names = @topic.posts.collect {|cat| "'#{cat.title}'"}.join(',')

      @hot_spot_ids = @topic.id_of_all_hot_spot_topic_id.join(',')
      @hot_spot_links = @topic.hot_spots.collect {|cat| "'/articles/#{cat.id}'"}.join(',')
      @hot_spot_names = @topic.hot_spots.collect {|cat| "'#{localized_description(cat, :name)}'"}.join(',')

      @travel_line_family = @topic_expo.travel_line_family.split(",") if @topic_expo and !@topic_expo.travel_line_family.blank?
      @travel_line_sweet = @topic_expo.travel_line_sweet.split(",") if @topic_expo and !@topic_expo.travel_line_sweet.blank?
      @travel_line_grandparent = @topic_expo.travel_line_grandparent.split(",") if @topic_expo and !@topic_expo.travel_line_grandparent.blank?
      @travel_line_child = @topic_expo.travel_line_child.split(",") if @topic_expo and !@topic_expo.travel_line_child.blank?

    else
      @topic = Topic.new
      @surl = admin_topics_path
      @method = nil
    end
  end

  def recommend
    @topic = Topic.find(params[:id])
    @hot_spot = HotSpot.find(params[:hot_spot_id])
    if @topic and @hot_spot and @topic.topic_expo
      @topic_expo = @topic.topic_expo
      tags = @hot_spot.hot_spot_tags.inject([]){|array,item| array << item.tag}
      column = []
      if tags.include? "时尚世博会"
        column << "square_ids_family"
      end

      if tags.include? "艺术世博展"
        column << "square_ids_sweet"
      end

      if tags.include? "低碳世博馆"
        column << "square_ids_grandparent"
      end

      if tags.include? "梦想世博版"
        column << "square_ids_child"
      end

      if @hot_spot.hot_spot_category and @hot_spot.hot_spot_category.root.name_zh_cn == "餐饮"
        column << "food_ids"
      end

      if column.blank?
        @message = "推荐未成功，请确认是否已加入标签或是否属于餐饮行业"
      else
        
        begin
          column.each do |x|
            if @topic_expo[x].blank?
              ids = @hot_spot.id
            else
              ids = (@topic_expo[x].split(",") << @hot_spot.id.to_s).uniq.join(",")
            end
            @topic_expo.update_attribute(x, ids)
          end
          @message = "推荐成功"
        rescue
          @message = "数据错误"
        end
      end
    else
      @message = "请检查是否有世博专题"
    end
    render :text => @message
  end

  def cancel_recommend
    @topic = Topic.find(params[:id])
    @hot_spot = HotSpot.find(params[:hot_spot_id])
    if @topic and @hot_spot and @topic.topic_expo
      @topic_expo = @topic.topic_expo

      column = ["square_ids_family", "square_ids_sweet", "square_ids_grandparent", "square_ids_child", "food_ids"]

      begin
        column.each do |x|
          unless @topic_expo[x].blank?
            ids = (@topic_expo[x].split(",").reject{|n| n.to_i == @hot_spot.id}).join(",")
          end
          @topic_expo.update_attribute(x, ids)
        end
        @message = "取消成功"
      rescue
        @message = "数据错误"
      end
    else
      @message = "请检查是否有世博专题"
    end
    render :text => @message
  end

end
