class BrandsController < ApplicationController
  layout 'default', :except=>[:products]
  helper 'cities'
  helper 'products' 
  helper 'promotions'
  helper 'hot_spot_categories'
  helper 'hot_spots'
   
  def index
    @brands = Brand.paginate :order=>'id desc', :per_page=>20, :page=>params[:page]
  end

  def show
    @brand = Brand.find params[:id] 
    @brand.visit_count! unless request.xhr?
  
    @hot_spots = HotSpot.paginate :per_page => 10, :conditions => ["brand_id = ? and city_id = ?", @brand.id, @current_city], :order => "name_#{current_lang}", :page=>params[:page] 
    logger.info "request.xhr? = #{request.xhr?}"
    if request.xhr?
      render :action=>'index_xhr', :layout=>false
    else
      respond_to  do |format|
        format.html {
            unless @hot_spots.empty?
              @start_point = @hot_spots[0].coordinate
            else
              @start_point = @current_city.start_point
            end
        }
        format.xml { render  :layout=>false }
      end    
    end
  end
  
  def capabilities
    @brand = Brand.find params[:id]
  	respond_to do |format|
  	format.xml {    render :layout=>false }
  	end
  end
  
  def hot_spots
    @current_city = City.find params[:city_id]
    @brand = Brand.find params[:id]
    parse_start_limit
    @hot_spots = HotSpot.paginate :conditions=>['brand_id = ? and city_id = ?', @brand.id, @current_city.id], :page=>@page, :per_page=>@per_page
  	respond_to do |format|
    		format.xml {
        render :layout=>false
    }
    end
  end
  
  def articles
    @brand = Brand.find params[:id]
    @articles = Article.paginate_by_brand_id  @brand.id,
                                :order => 'created_at desc',
                                :page=>params[:page]
    render :partial=> 'articles/article_list', :layout=>false
  end
  
  def products
    @brand = Brand.find params[:id]
    @products = Product.paginate :conditions=>['vendor_type = ? and vendor_id = ?', 'Brand', @brand.id],
                                 :order=>'created_at desc',
                                 :page=>params[:page],
                                 :per_page=>4
    
  end
  
  def map
    brand = Brand.find params[:id]
    @brands_count, @brands = 1, [brand]
    @show_brand_map = true
    render :template => '/cities/map'
  end
end
