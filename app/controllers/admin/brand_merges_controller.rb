class Admin::BrandMergesController < ApplicationController
  before_filter :is_admin
  before_filter :find_brand

  layout 'admin', :only=>[:index, :preview, :create]
  
  def index
    @keyword = @brand.name[@current_lang]
    do_search("%#{@keyword}%")
    render :action=>'search_target', :layout=>false if request.xml_http_request?
  end
  
  def create
    @target = Brand.find params[:target_id]
    Brand.transaction do
      if @target.update_attributes(params[:target]) 
        @target.merge_from @brand
      else
        render :action => "preview"
        return
      end
    end
    redirect_to manage_brands_path
  end
  
  def search_target
    keyword = "%#{params[:keyword]}%"
    do_search(keyword)
  end
  
  def preview
    @target = Brand.find params[:target_id]
  end
  
  private 
  def find_brand
    @brand = Brand.find(params[:brand_id])    
  end
  
  def do_search(keyword)
    @targets = Brand.paginate :conditions=>['id <> ? and ((name_zh_cn like ?) or (name_en like ?))', @brand.id, keyword, keyword],
                                :order=>"name_#{@current_lang}", :page => params[:page], :per_page => 2
  end
  
end
