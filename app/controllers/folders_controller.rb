class FoldersController < ApplicationController
  before_filter :find_member
  before_filter :authenticated, :except=>[:index, :show]
  before_filter :check_privilege, :except => ['index', 'show'] 
  layout 'default', :only=>['index', 'show']
  helper 'articles'
  
  def index
    @folders = @member.folders
  end
  
  def show
    @folder = @member.folders.find params[:id]
    respond_to do |format|
      format.html {
        @articles = Article.paginate_by_folder_id @folder.id, 
                                    :order => 'updated_at desc',
                                    :page=>params[:page]
      }
      format.rss {
        @articles = @folder.articles.latest_articles 10
        render :template => 'folders/feed', :layout=>false 
      }
    end
    
  end
  
  def new
    @folder = @member.folders.new
  end
  
  def create
    @folder = @member.folders.build params[:folder]
    if @folder.save
      render :layout=>false
    else
      render :action=>'show_form_error'
    end
  end
  
  def edit
    @folder = @member.folders.find params[:id]
  end
  
  def update  
    @folder = @member.folders.find params[:id]
    if @folder.update_attributes params[:folder]
      render :layout => false
    else
      render :action => 'show_form_error'
    end
  end
  
  def destroy
    @folder = @member.folders.find params[:id]
    @folder.destroy
    render :layout => false
  end
  
  private
  def find_member
    @member = Member.find params[:member_id]
  end
  
  def check_privilege
    unless @member == @current_user
      alert _('You have no privilege to do this operation.')
      return false
    end
  end
end
