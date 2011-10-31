require 'class_util'
require 'dynamic_query'

class LayoutMapsController < ApplicationController  
  include Imon::Utilities
  include Imon::DynamicQuery
  
  before_filter :find_layoutable    
  helper 'hot_spot_categories'
  helper 'inner_hot_spots'
  helper 'hot_spots'
  
  layout 'default', :except=>[:hot_spots_by_category, :category_navigator, :to_search, :search]
  
  def index           
    respond_to do |wants|
      wants.html { 
        adjust_current_city(@layoutable.city) if @layoutable.respond_to? :city
        @layout_maps = @layoutable.layout_maps
        render 
      }
      wants.js   { 
        request.headers['content-type'] = 'text/javascript'   
#        render :template=>'layout_maps/layout_maps_data', :layout=>false
        render :layout=>false
      }
      wants.xml {
        @layout_maps = @layoutable.layout_maps_has_zoom_levels
        render :layout=>false
      }
    end
  end                 
    
  def search
    join_tables = []
    if params[:layout_map_id] and !params[:layout_map_id].empty?
      spec = [self.equal(:layout_map_id, params[:layout_map_id])]
    else
      spec = [self.equal(:layoutable_type, @layoutable.class.to_s), self.equal(:layoutable_id, @layoutable.id)];
      join_tables  << :layout_map
    end
    if params[:keyword] and !params[:keyword].empty?
      keyword = params[:keyword]
      spec << self.or(self.like('hot_spots.name_zh_cn', keyword), self.like('hot_spots.name_en', keyword))
      join_tables << :hot_spot
    end
    cat = nil
    if params[:hot_spot_category_id]
      cat = HotSpotCategory.find params[:hot_spot_category_id]
    else
      cat = find_hot_spot_category(params[:hot_spot_category_root_id], params[:hot_spot_category_children_id])
    end
    
    unless cat.nil?
      cat_ids = cat.id_of_all_children_include_self
      spec << self.in('hot_spots.hot_spot_category_id', cat_ids)
      join_tables << :hot_spot
    end
    if (tag = params[:tag]) and !params[:tag].empty?
      spec << self.exists('select * from hot_spot_tags t where t.hot_spot_id = hot_spots.id and t.tag like ? ', "%#{tag}%")
    end
    conditions = self.and(spec).conditions
    @positions = Position.paginate :conditions=>conditions, :include=>join_tables.flatten, :page=>params[:page], :per_page=>5
    render :layout=>false
  end
  
  private
  def find_layoutable
    layoutable_class = class_for_name params[:layoutable_class]
    @layoutable = layoutable_class.send(:find, params[:layoutable_id])
  end
  
  def count_hot_spots_by_root_category
    @hot_spot_counts = {}
    @hot_spots_by_category_map = {}
    @layoutable.hot_spots.each do |hot_spot|
      cat = hot_spot.hot_spot_category.root
      c = @hot_spot_counts[cat] || 0
      c += 1
      @hot_spot_counts[hot_spot.hot_spot_category.root] = c
      a = @hot_spots_by_category_map[cat] || []
      a << hot_spot
      @hot_spots_by_category_map[cat] = a
    end
  end
end
