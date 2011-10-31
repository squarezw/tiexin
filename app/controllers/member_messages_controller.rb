class MemberMessagesController < ApplicationController
  layout 'default'
  before_filter :authenticated
  before_filter :find_or_initialize
  before_filter :check_privilege
  
  def index
  end
  
  def sent
    @title = 'Outbox'
    @messages = Message.paginate_by_from_id @member.id,
                                    :order => 'created_at desc',
                                    :conditions => 'sender_deleted = false',
                                    :page=>params[:page]
    render :action => 'index'
  end
  
  def received
    @title = 'Inbox'
    if @mobile_user
      parse_start_limit
    else
      @page = params[:page]
      @per_page = 10
    end
    @messages = Message.paginate_by_to_id @member.id,
                                    :order => 'created_at desc',
                                    :conditions => 'receiver_deleted = false',
                                    :page=>@page, 
                                    :per_page=>@per_page
    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml { render :action=> 'index', :layout=>false }
    end
  end

  def has_not_read
    if @mobile_user
      parse_start_limit
    else
      @page = params[:page]
      @per_page = 10
    end
    @title = 'Unread Messages'
    @messages = Message.paginate :conditions => ["to_id = ? and readed = ? and receiver_deleted = 0" , @member.id, false],
                                 :order => 'created_at desc',
                                 :page => @page, :per_page=>@per_page
     respond_to do |format|
       format.html { render :action => 'index' }
       format.xml { render :action=> 'index', :layout=>false }
     end
  end
  
  def new
    @message = Message.new

  end
  
  def create
    @message = Message.new(params[:message])
    if member = find_member(params[:member][:nick_name])
      @message.to_id =   member.id
    end
    
    @message.from_id = @member.id
    if @message.save
      flash[:notice] = _('Message was successfully sent') 
      redirect_to sent_member_messages_path(@member.id)
    else
      render :action => "new"
    end
  end
  
  def show
    if Message.find(:first,:conditions => ["((from_id = ? and sender_deleted = false) or (to_id = ? and receiver_deleted = false)) and id = ?",@current_user.id,@current_user.id,params[:id]])
      @message = Message.find(params[:id])
      if @member.id == @message.to_id
        Message.set_readed(params[:id])
      end
      respond_to do |format|
        format.html
        format.xml { render :layout=> false }
      end
    else
      respond_to do |format|
        format.html {
          flash.now[:note] = _('You have no privilege to do this operation.')
          redirect_to member_path(@member)
        }
        
        format.xml {
          error_xml 208
        }
      end
    end
  end
  
  def destroy
    @message = Message.find(params[:id])
    check_deleted(@message)
    flash.now[:note] = _('The message has been deleted.')
    render :template=>'/simple_message'
  end
  
  private
  def find_or_initialize
    @member = Member.find(params[:member_id])
  end
  
  def find_member(name)
    Member.find(:first, :conditions => ["nick_name = ?", name])
  end
 
  def check_privilege
    return true if @member.modifiable_to?(@current_user) 
    flash.now[:note] = _('You have no privilege to do this operation.')
    redirect_to member_path(@member)
  end
  
  def check_deleted(message)
    if message.from_id == @current_user.id
       message.deleted_from_sender
    end
    if message.to_id == @current_user.id
       message.deleted_from_receiver
    end
    if message.can_delete?
        message.destroy
    end
  end
end
