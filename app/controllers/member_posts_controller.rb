class MemberPostsController < ApplicationController
  before_filter :authenticated, :except=>[:index]
  before_filter :find_member
  
  layout 'default'
    
  def index
    if @current_user && @member.id == @current_user.id
        conditions = ["check_status = ? and member_id = ? ",Post::STATUS_CHECKED,@member.id]
    else
        conditions = ["check_status = ? and deleted = ? and member_id = ? ",Post::STATUS_CHECKED, false, @member.id]  
    end
    @posts = Post.paginate  :conditions=> conditions,
                            :order=>'updated_at desc, created_at desc',
                            :page=>params[:page]

  end

  private 
  def find_member
    @member = Member.find params[:member_id]
  end  
end
