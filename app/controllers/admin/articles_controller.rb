require 'privilege'

class Admin::ArticlesController < ApplicationController
  before_filter :authenticated
  before_filter :is_admin
  layout 'default'
  helper 'operation_logs'
  
  include XNavi::Privilege
  
  def index
    @articles = Article.paginate :order=>'created_at desc', :page=>params[:page], :per_page=>20
  end
  
  def show
    @article = Article.find params[:id]
  end
  
  def approve
    @article = Article.find params[:id]
    Article.transaction do 
      old_status = @article.check_status
      @article.approve!
      new_status = @article.check_status
      OperationLog.create (:member=>@current_user, 
                           :related_object=>@article, 
                           :operation=>'check_article',
                           :message_key=>'Change check status from "%{old_status}" to "%{new_status}"',
                           :message_parameters=>{:old_status=>"article_check_status|#{old_status}",
                                                 :new_status=>"article_check_status|#{new_status}"} )
      
    end
    redirect_to  :action=>:show
  end
  
  def disapprove
    @article = Article.find params[:id]
    Article.transaction do 
      old_status = @article.check_status
      @article.disapprove!
      new_status = @article.check_status
      OperationLog.create (:member=>@current_user, 
                           :related_object=>@article, 
                           :operation=>'check_article',
                           :message_key=>'Change check status from "%{old_status}" to "%{new_status}"',
                           :message_parameters=>{:old_status=>"article_check_status|#{old_status}",
                                                 :new_status=>"article_check_status|#{new_status}"} )
      
    end
    redirect_to  :action=>:show
  end
  
  N_('Delete article %{subject}.')
  def destroy
    @article = Article.find params[:id]
    Article.transaction do 
      @article.destroy
      OperationLog.create (:member=>@current_user, 
                           :related_object=>nil, 
                           :operation=>'check_article',
                           :message_key=>'Delete article %{subject}.',
                           :message_parameters=>{:subject => @article.subject })
    end
    redirect_to :action => "index"
  end
end
