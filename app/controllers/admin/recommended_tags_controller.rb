class Admin::RecommendedTagsController < ApplicationController
  before_filter :authenticated
  before_filter :is_admin
  
  layout 'admin'
  
  def index
    @tags = RecommendedTag.find :all
    @recommended_tag = RecommendedTag.new
  end
  
  def create
    tag = RecommendedTag.find_by_tag params[:recommended_tag][:tag]
    if tag.nil?
      @recommended_tag = RecommendedTag.new params[:recommended_tag]
      unless @recommended_tag.save
        render :update do |page|
          page.replace_html 'form_error', error_messages_for(:recommended_tag)
        end
      end
    else
      render :update do |page|
        page.alert _('The tag has already been recommended.')
      end
    end
  end
  
  def destroy
    @tag = RecommendedTag.find params[:id]
    @tag.destroy
    redirect_to :action => "index"
  end
end
