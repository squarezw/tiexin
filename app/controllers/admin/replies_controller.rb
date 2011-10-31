require 'scores'

class Admin::RepliesController < ApplicationController
  include XNavi::Score
  
  before_filter :authenticated
  before_filter :is_admin
  before_filter :find_reply, :except=>[:index]
  
  layout 'admin'
  
  def index
    @replies= Reply.paginate :order=>'updated_at desc', :page => params[:page]
  end
  
  def check
    check_status = params[:check_status].to_i    
    if Reply::ALL_CHECK_STATUS.include? check_status
      Reply.transaction do 
        old_status = @reply.check_status
        @reply.update_attribute_with_validation_skipping :check_status, check_status
        OperationLog.create (:member=>@current_user, 
                             :related_object=>@reply, 
                             :operation=>'check_reply',
                             :message_key=>'Change check status from "%{old_status}" to "%{new_status}"',
                             :message_parameters=>{:old_status=>"reply_check_status|#{old_status}",
                                                   :new_status=>"reply_check_status|#{check_status}"} )
      end
    end
    redirect_to :action => "show"
  end
  
  def destroy
    subtract_credit = params[:subtract_credit].to_i
    if subtract_credit > 0
      score :delete_reply, @reply.member, -subtract_credit
    end
    Post.transaction do 
      @reply.deleted!
      OperationLog.create :member=>@current_user,
                          :related_object =>@reply,
                          :operation=>'delete_reply',
                          :message_key=>'Delete reply to %{post} which is posted by %{member}',
                          :message_parameters=>{ :post=> @reply.post.title,
                                                 :member=> @reply.member.nick_name },
                          :memo => params[:delete_reson]
    end
    flash.now[:note] = _('The reply has been deleted.')
    render :action => "show"
  end
  
  private
  def find_reply
    @reply = Reply.find params[:id]
  end
end
