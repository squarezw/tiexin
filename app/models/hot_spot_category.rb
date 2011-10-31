require 'imon_exception'

class HotSpotCategory < ActiveRecord::Base
  acts_as_tree          
  acts_as_multilingual_attribute :name
  
  image_column :icon, :validate_integrity=>false
  image_column :map_icon, :validate_integrity=>false
  image_column :big_icon, :validate_integrity=>false
  
  validates_integrity_of :icon
  validates_integrity_of :map_icon
  validates_integrity_of :big_icon
  validates_presence_of :name
  validates_length_of_multilingual_attribute :name, :lang => XNavi::SUPPORT_LANGS, :within=>0..20, :allow_nil => true
  validates_numericality_of :order_weight, :only_integer => true
  validates_length_of :keyword, :maximum=>100, :allow_nil=>true
  
  untranslate :icon_mimi_type, :icon_filesize
   
  def self.roots(order='order_weight desc')
    self.find_all_by_parent_id(nil, :order=>order)
  end            
  
  def self.name_contains(keyword)
    kw = "%#{keyword}%"
    self.find :all, :conditions=>['name_zh_cn like ? or name_en like ? ', kw, kw]
  end
  
  def self.common_categories
    self.find :all, :conditions=>['common = ? ', true]
  end
  
  def <=>(cat2)
    self.order_weight == cat2.order_weight ? self.id <=> cat2.id : self.order_weight <=> cat2.order_weight
  end
  
  def path
    self.parent.nil? ? [self] : self.parent.path + [self]    
  end
  
  def before_destroy
    return true if self.children.blank? and there_no_hot_spots?
    raise Imon::CantDestroyException 
  end       

  def all_children
    self.children.inject([]) { |children, cat| 
      children.concat(cat.all_children_include_self) 
    }
  end
  
  def all_children_include_self
    self.children.inject([self]) { |children, cat| 
      children.concat(cat.all_children_include_self) 
    }
  end                  

  def id_of_all_children_include_self
    all_children_include_self.collect { |cat| cat.id }
  end
  
  def level
    self.ancestors.length
  end                    
  
  def is_traffic_stop?
    TrafficLine::TYPES.include? self.traffic_stop_type 
  end                 
  
  def safe_big_icon
    self.big_icon || (self.parent ? self.parent.safe_big_icon : nil)
  end                    
  
  def keywords_array
    (self.keyword and !self.keyword.blank?) ? self.keyword.split(/[,，]/) : []
  end
  
  private
  def there_no_hot_spots?
    HotSpot.count(:conditions=>['hot_spot_category_id = ?', self.id]) == 0
  end

end
