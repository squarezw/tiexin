class MemberCommentsController < ApplicationController
  layout 'default'
  helper 'comments'
  
  # A user can view all of comments posted by himself, including those are waiting check.
  # But for comments posted by other member, he can only view published comments.
  def index
    @member = Member.find(params[:member_id])
    if @member == @current_user
      conditions = ['member_id = ?', @member.id]
    else
      conditions = ['member_id = ? and status = ?', @member.id, Comment::STATUS_PUBLISHED]
    end
    @comments = Comment.paginate :conditions => conditions,
                                :order=>'created_at',
                                :page=>params[:page]
  end
end
