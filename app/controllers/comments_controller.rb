require 'scores'

class CommentsController < ApplicationController    
  include XNavi::Score
      
  before_filter :find_commentable     
  before_filter :authenticated, :except=>[:index, :new]
  before_filter :is_admin, :only=>[:destroy]
  before_filter :find_comment, :only=>[:destroy, :agree, :disagree]
  before_filter :can_vote, :only=>[:agree, :disagree]
  
  def index
    respond_to do |format|
      format.html {   @comments = paginate_comments
                      @comment = @commentable.comments.build
                  }
      format.xml {
        order_direction = params[:order_direction] || 'asc'
        start = params[:start] if params.has_key?(:start)
        limit = params[:limit] if params.has_key?(:limit)
        condition = ['status = ?', Comment::STATUS_PUBLISHED]
        @count = @commentable.comments.count :conditions=>condition
        @comments = @commentable.comments.find(
            :all, 
            :conditions=>condition, 
            :order => "created_at #{order_direction}", :offset => start, :limit => limit )
#        render :template => 'comments/index.rxml'
      }
    end
  end
  
  def new
    if @current_user
      @comment = @commentable.comments.build
      render :layout=>false
    else
      render :text=>_('You can post comment after login.')
    end
  end
  
  def create
    @comment = @commentable.comments.build(params[:comment])      
    @comment.member = @current_user
    @comment.status = TabooWord.check(@comment.content) ? Comment::STATUS_PUBLISHED : Comment::STATUS_WAITING_CHECK

    if @comment.valid?  
        @comment.save
        if @comment.waiting_check?
          render :update do |page|
            page.alert _('Your comment including taboo words. Waiting administrator to check manually.')
            page << '$("comment_content").value="";'
          end
        else
          score :post_comment
          @last_page = (published_comments_count_of(@commentable) - 1) / 10 + 1
        end
      else
         respond_to do |format|
            format.js {
              render :update do |page|
                page.replace_html 'div_comment_form', :partial=>'new'
              end              
            }
            format.xml{
              render :template => "comments/error.rxml", :layout=>false
              return
            }
         end
   end

    respond_to do |format|
      format.js {}
      format.xml {
          render :template => "comments/create.rxml", :layout=>false
      }      
    end
  end
    
  
  def quote
    @quoted = @commentable.comments.find params[:id]
    @comment = @commentable.comments.build(:content=>"[quote=#{@quoted.member.nick_name}]#{@quoted.content}[/quote]")
    render :action => :new
  end 
  
  def destroy
    @comment.destroy
  end
  
  def agree
    Comment.transaction do
      @comment.agree_by @current_user
      @comment.save
      score :comment_agree, @comment.member if @comment.agree == 5 and @comment.disagree < 5
    end
    render :template=>'comments/comment'
  end
  
  def disagree
    Comment.transaction do
      @comment.disagree_by @current_user
      @comment.save
      score :comment_disagree, @comment.member if @comment.disagree == 5 and @comment.agree < 5
    end
    render :template=>'comments/comment'
  end
  
  private
  def find_commentable    
    commentable_class = params[:commentable_type].camelize.split("::").inject(Object) { |par, const| par.const_get(const) }
    @commentable = commentable_class.send(:find, params[:commentable_id])
  end                   
  
  def paginate_comments
    return Comment.paginate :conditions => ['commentable_type = ? and commentable_id=? and status =?', @commentable.class.to_s, @commentable.id, Comment::STATUS_PUBLISHED],
             :order => 'created_at', :page=>params[:page]
  end        
  
  def published_comments_count_of(commentable)
    @commentable.comments.count(:conditions=>['status = ?', Comment::STATUS_PUBLISHED])
  end
  
  def find_comment
    @comment = @commentable.comments.find params[:id]
  end
  
  def can_vote
    return true if @comment.can_vote_by? @current_user
    flash.now[:note] = _('You have no privilege to do this operation.')
    render :template => '/js_alert'  
    return false
  end
end
