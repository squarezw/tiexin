require 'scores'

class RepliesController < ApplicationController
  SCORE_EVENTS = {Reply::VOTE_GOOD => :good_reply,
                  Reply::VOTE_HIDDEN => :hidden_reply }
                  
  include XNavi::Score
  
  before_filter :authenticated
  before_filter :find_forum
  before_filter :find_post
  before_filter :find_reply, :only=>[:edit, :update, :vote]
  before_filter :is_post_locked
  
  layout 'default', :only=>[:new, :quote, :edit]
  
  def new
    @reply = @post.replies.new
  end
  
  def create
    @reply = @post.replies.build params[:reply]
    @reply.member = @current_user
    @reply.check_status = TabooWord.check(@reply.content) ? Reply::STATUS_CHECKED : Reply::STATUS_PENDDING
    if @reply.save
      @post.replied!
      score :new_reply, @current_user
      last_page = (@reply.position - 1) / 10 + 1
      redirect_to :controller=>'posts', :action=>'show', :forum_id=>@forum.id, :id=>@post.id, :page=>last_page
    else
      render :action => "new", :layout=>'default'
    end
  end
  
  def edit
  end
  
  def update
    @reply.attributes= params[:reply]
    @reply.check_status = TabooWord.check(@reply.content) ? Reply::STATUS_CHECKED : Reply::STATUS_PENDDING
    if @reply.save
      flash[:note] = _("Your reply including taboo words. Waiting administrator to check manually.") if @reply.check_status == Reply::STATUS_PENDDING    
      redirect_to forum_post_path(@forum, @post)
    else
      render :action => "edit", :layout=>'default'
    end
    
  end
  
  def quote
    be_quoted = @post.replies.find params[:id]
    @reply = @post.replies.new
    @reply.content = "[quote=#{be_quoted.member.nick_name}]#{be_quoted.content}[/quote]"
    render :action => "new"
  end
  
  def vote
    if @reply.votable_to? @current_user
      begin
        old_vote_result = @reply.vote_result
        @reply.vote! @current_user, params[:option].to_i
        @reply.save_with_validation
        if old_vote_result == 0 and old_vote_result != @reply.vote_result
          score SCORE_EVENTS[@reply.vote_result], @reply.member if SCORE_EVENTS.has_key?(@reply.vote_result)
        end
        @message = _('Your vote has been saved.')
      rescue ArgumentError 
        @message = 'Invalid vote option.'
      end
    end
    render :partial=>'/posts/reply_vote_area', :locals=>{:reply=>@reply}
  end
  
  private
  def find_forum
    @forum = Forum.find params[:forum_id]
  end
  
  def find_post
    @post = @forum.posts.find params[:post_id]
  end
  
  def find_reply
    @reply = @post.replies.find params[:id]
  end
  
  def is_post_locked
    if @post.lock
      flash[:note] = _('Post is locked.')
      redirect_to forum_post_path(@forum, @post)
      return false
    end
  end
end
