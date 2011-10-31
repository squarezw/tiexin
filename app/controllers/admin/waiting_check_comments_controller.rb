class Admin::WaitingCheckCommentsController < ApplicationController      
  before_filter :is_admin
  layout 'admin'        
  helper 'admin/taboo_words'
  
  def index
    @comments = Comment.paginate :order => 'status desc,created_at desc', :page=>params[:page], :per_page => 30
  end    
  
  def show
    @comment = Comment.find(params[:id])
    unless @comment.waiting_check?
      flash[:note] = _('It is unnecessary to check this comment.')
      redirect_to :action => :index 
    end
  end             
  
  def pass
    @comment = Comment.find(params[:id])
    @comment.pass_check!
    @comment.save
    redirect_to :action => "index"
  end     
  
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    redirect_to :action => "index"
  end
end
