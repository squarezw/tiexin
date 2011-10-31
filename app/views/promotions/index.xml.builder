xml.result(:code=>100) do
  @promotions.each do |promotion|
    attrs = {:id => promotion.id, 
            :begin_date => promotion.begin_date,
            :end_date => promotion.end_date, 
            :summary => localized_description(promotion, :summary) }
    attrs[:picture] = promotion.banner.url if promotion.banner
    xml.promotion localized_description(promotion, :content), attrs
#    xml.promotion attrs do 
#      xml.cdata! localized_description(promotion, :content)
#    end
  end
end