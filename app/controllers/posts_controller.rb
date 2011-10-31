require 'scores'
require 'dynamic_query'

class PostsController < ApplicationController
  include Imon::DynamicQuery
  
  SCORE_EVENTS = {Post::VOTE_GOOD => :good_post,
                  Post::VOTE_HIDDEN => :hidden_post,
                  Post::VOTE_WATER => :water_post }
  include XNavi::Score
  
  before_filter :find_forum, :except=>[:bind]
  before_filter :find_post, :only=>[:show, :edit, :update, :quote, :vote]
  before_filter :authenticated, :except=>[:index, :show, :vote]
  before_filter :check_privilege, :only=>[:edit, :update, :destroy]
  before_filter :option, :only=>[:index, :show]
  
  auto_complete_for :tag, :tag, :limit => 10
  
  layout 'default'
  helper 'operation_logs'
  helper 'members'
  
  def index
    blacklist_check(@forum,@current_user)
    exps = [self.equal(:forum_id, @forum.id),
            self.not_equal(:vote_result, Post::VOTE_HIDDEN),
            self.equal(:always_on_top, false),
            self.less_or_equal(:check_status, Post::STATUS_CHECKED),
            self.not_equal(:deleted, true)]
    exps << self.not_equal(:vote_result, Post::VOTE_WATER) if @hide_water_post
    @posts = Post.paginate :conditions=>self.and(exps).conditions,
                           :order=>'last_replied_at desc, created_at desc',
                           :page=>params[:page]
  end
  
  def new
    @post = @forum.posts.new
  end
  
  def create
    @post = @forum.posts.build params[:post]
    @post.member = @current_user
    #@post.check_status = TabooWord.check(@post.content) ? Post::STATUS_CHECKED : Post::STATUS_PENDDING 自动审核关键字
    @post.check_status = @current_user.is_admin or @current_user.has_privilege(:manage_forum) ? Post::STATUS_CHECKED : Post::STATUS_PENDDING # 人工审核
    Post.transaction do
      if @post.save
        save_post_tags @post
        #flash[:note] = _("Your post including taboo words. Waiting administrator to check manually.") if @post.check_status == Post::STATUS_PENDDING
        flash[:note] = _("Your post published. Waiting administrator to check manually.") if @post.check_status == Post::STATUS_PENDDING
        score :new_post, @current_user
        redirect_to :action => "index"
      else
        render :action => "new"
      end
    end
  end
  
  def show
    blacklist_check(@forum,@current_user)
    if @post.deleted and !current_is_admin?
      flash[:note] = _('This post has been deleted by administrator.')
      redirect_to :action => "index"
      return
    end
    
    @post.read!
    if @hide_water_reply
      cond = ['post_id = ? and vote_result <> ?', @post.id, Reply::VOTE_WATER]
    else
      cond = ['post_id = ?', @post.id]
    end
    @replies = Reply.paginate  :conditions=>cond,
                               :order=>'created_at',
                               :per_page=>10,
                               :page=>params[:page]
    @reply = @post.replies.new
  end
  
  def edit
      @tags_string = @post.tags_string
  end
  
  def update
    @post.attributes= params[:post]
    @post.check_status = TabooWord.check(@post.content) ? Post::STATUS_CHECKED : Post::STATUS_PENDDING
    Event.transaction do 
      if @post.save
        save_post_tags @post
        if @post.check_status == Post::STATUS_PENDDING
          flash[:note] = _("Your post including taboo words. Waiting administrator to check manually.")
          redirect_to :action => "index"
        else
          redirect_to :action => "show"
        end
      else
        render :action => "edit"
      end
    end
  end
  
  def quote
    @reply = @post.replies.new 
    @reply.content = "[quote=#{@post.member.nick_name}]#{@post.content}[/quote]"
    render :template=>'/replies/new'
  end
  
  def vote
    if @post.votable_to? @current_user
      old_vote_result = @post.vote_result
      begin
        @post.vote! @current_user, params[:option].to_i
        @post.save_with_validation
        if old_vote_result == 0 and old_vote_result != @post.vote_result
          logger.info "score event: #{SCORE_EVENTS[@post.vote_result]}"
          score SCORE_EVENTS[@post.vote_result], @post.member if SCORE_EVENTS.has_key?(@post.vote_result)
          score SCORE_EVENTS[@post.vote_result], @post.member if SCORE_EVENTS.has_key?(@post.vote_result) and @post.original
        end
        @message = _('Your vote has been saved.')
      rescue ArgumentError 
        @message = 'Invalid vote option.'
      end
    end
    render :partial=>'post_vote_area'
  end
  
  def set_option
    cookies[:hide_water_post] = params[:hide_water_post]
    cookies[:hide_water_reply] = params[:hide_water_reply]
    redirect_to :action => "index"
  end
  
  private
  def find_forum
    @forum = Forum.find params[:forum_id]
  end
  
  def find_post
    @post = @forum.posts.find params[:id]    
  end
  
  def check_privilege
    return true if @post.modifiable_to?(@current_user)
    flash.now[:note] = _('You have no privilege to do this operation.')
    redirect_to :action => "show"
  end
  
  def option
    @hide_water_post =  (cookies[:hide_water_post] == '1')
    @hide_water_reply = (cookies[:hide_water_reply] == '1')
    return true
  end
  
  def blacklist_check(forum,current_user)
     if forum.blacklist_to_members.include? current_user
      flash[:note] =  _('You Can not enter the forum.')
      redirect_to forums_path
     end
  end
  
  def save_post_tags(post)
    @tags_string ||= params[:tag][:tag]
    post.tags_string= @tags_string
  end
  
end
