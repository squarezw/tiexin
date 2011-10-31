class MemberPromotionsController < ApplicationController
  layout 'default'
  helper 'promotions'
  
  before_filter :authenticated, :except=>[:index]
  before_filter :find_or_initialize, :except => [:index]
 
  def index
    @member = Member.find(params[:member_id])
    @promotions = Promotion.paginate_by_member_id @member.id,
                                 :order => 'created_at desc',
                                 :page=>params[:page],
                                 :per_page=>20
  end
  
  def edit
    if params[:vendor_type] == 'HotSpot'
      @HotSpot = @vendor
    else
      @Brand = @vendor
    end
  end
  
  def create
    if params[:vendor_type] == 'HotSpot'
      vendor_id = params[:HotSpot][:vendor_id]
    else
      vendor_id = params[:Brand][:vendor_id]
      city = params[:city]
    end
    unless vendor_id.blank?
      find_vendor(vendor_id)
      @promotion = @vendor.promotions.build(params[:promotion])
      @promotion.member = @current_user
      if @vendor.respond_to? :city
        @promotion.cities << @vendor.city
      else
        @promotion.cities << City.find(params[:city]) if city
      end
      if @promotion.save
        flash[:notice] = _('Promotion was successfully created.')
        redirect_to member_promotions_path
      else
        #@Hotspot = vendor_id
        #@Brand = vendor_id
        render :action => "new"
      end
    else
      render :action => "new"
    end
  end
  
  def update
    if params[:vendor_type] == 'HotSpot'
      vendor_id = params[:HotSpot][:vendor_id]
    else
      vendor_id = params[:Brand][:vendor_id]
      city = params[:city]
    end
    unless vendor_id.blank?
        find_vendor(vendor_id)
        @promotion = Promotion.find(params[:id]) 
        @promotion.cities.clear
        if @vendor.respond_to? :city
          @promotion.cities << @vendor.city
        else
          @promotion.cities << City.find(city) if city
        end
      if @promotion.update_attributes(params[:promotion].merge(:vendor=>@vendor))
            flash[:notice] = _('Promotion was successfully updated.')
            redirect_to member_promotions_path
        else
            if params[:vendor_type] == 'HotSpot'
               @HotSpot = @vendor
            else
               @Brand = @vendor
            end
            render :action=>'edit'
        end
    else
       render :action=>'edit'
    end
  end

  def destroy
    @promotion.destroy
    redirect_to member_promotions_path
  end
  
  protected
  def find_or_initialize
    @cities = City.find(:all)
    @hotspots = @current_user.owned_hot_spots
    @brands = @current_user.owned_brands
    @member = Member.find(params[:member_id])
    
    if params[:id]
      @promotion = @member.promotions.find params[:id]
    else
      @promotion = Promotion.new
    end
    
    if params[:vendor_type] && params[:id] && params[:vendor_id]
      find_vendor(params[:vendor_id])
    end
  end
  
  private
  def find_vendor(vendor_id)
    vendor_class = params[:vendor_type].camelize.split("::").inject(Object) { |par, const| par.const_get(const) }
    @vendor = vendor_class.send(:find, vendor_id)
  end
end
