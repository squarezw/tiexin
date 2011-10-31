class StaticController < ApplicationController
  layout 'default', :except=>[:test, :activity_200905]
  
  helper :mobile_brands,:mobile_models

  def download_m
    if params["mobile_brand_id"]
      mobile_brand = MobileBrand.find(params["mobile_brand_id"].to_i)
      @mobile_models = mobile_brand.mobile_models
    else
      @mobile_brands = MobileBrand.find(:all)
    end
    render  :layout=>'mobile'
  end
  
  def download
    @mobile_brands = MobileBrand.find(:all)
    @mobile_oss = MobileOs.find(:all)
  end
  
  def soa
    render :layout=>false
  end
  
  def soa_end
    render :layout=>'default'
  end
end
