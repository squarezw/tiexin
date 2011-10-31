module ChannelsHelper
  ORDER_OPTIONS = {}
  def query_criteria_string
    result = []
    result << @area_name unless @area_name.nil? or @area_name.empty?
    result << localized_description(@hot_spot_category, :name) unless @hot_spot_category.nil?
    result << @tag unless @tag.nil? or @tag.empty?
    result << @brand_name unless @brand_name.nil? or @brand_name.empty?
    return result.empty? ? '' : "(#{result.join(',')})"
  end
end
