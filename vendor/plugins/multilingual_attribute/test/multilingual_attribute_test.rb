require File.dirname(__FILE__)+'/abstract_unit'
require File.dirname(__FILE__)+'/fixtures/attribute_holder'

class MultilingualAttributeTest < Test::Unit::TestCase
  fixtures :attribute_holders
  include Imon::Acts::MultilingualAttribute::Helper
                                  
  def setup
    super
    @attr_holder=AttributeHolder.new
  end      
  
  def test_mixin_in_methods
    assert(@attr_holder.respond_to?(:name), "getter method hasn't been defined.")
  end                   
  
  def test_read_write_like_attribute
#    @attr_holder.name={:en=>'en', :zh_CN=>'zh', :jp=>'jp'} 
    @attr_holder.name.en='en'
    @attr_holder.name.zh_CN='zh'
    @attr_holder.name.jp='jp'
    assert_not_nil(@attr_holder.save) 
    @attr_holder=AttributeHolder.find(@attr_holder.id) 
    assert_equal('en', @attr_holder.name.en)
  end                   
  
  def test_read_value_like_hash
    @attr_holder=AttributeHolder.find(1)  
    assert_equal('en', @attr_holder.name[:en])
  end             

  def test_batch_set_value
    @attr_holder.name.set_values :en=>'en', :zh_CN=>'zh', :jp=>'jp'
    assert_equal('en', @attr_holder.name.en)
    assert_equal('zh', @attr_holder.name.zh_CN)
  end
   
  def test_set_with_equal_sign
    @attr_holder.name={ :en=>'en', :zh_CN=>'zh'}
    assert_equal('en', @attr_holder.name.en)
    assert_equal('zh', @attr_holder.name.zh_CN)    
  end         
  
  def test_blank  
    assert(@attr_holder.name.blank?) 
    @attr_holder.name.en='en'
    assert(!@attr_holder.name.blank?)
  end    
  
  def test_unknown_language
    assert_raises(NoMethodError) { @attr_holder.name.unknown_lan } 
#@attr_holder.name.unknown_lan
  end       
  
  def test_validates_presence_of_multilingual_attribute 
    assert(! @attr_holder.valid?)
    assert_not_nil(@attr_holder.errors[:name])
    @attr_holder.name.en='en'
    assert(@attr_holder.valid?)
    assert_nil(@attr_holder.errors[:name])
  end  
  
  def test_all_lang
    @attr_holder.name.set_values :en=>'en', :zh_CN=>'zh', :jp=>'jp'
    all_lang=@attr_holder.name.all_lang
    assert_equal(3, all_lang.size)
    assert(all_lang.has_key?(:en))
    assert(all_lang.has_key?(:zh_CN))
    assert(all_lang.has_key?(:jp))
  end                     
  
  def test_respond_to
    assert(@attr_holder.name.respond_to?('en'))
    assert(@attr_holder.name.respond_to?('en='))
  end
  
  def test_localized_description
    @attr_holder.name.set_values :en=>'en', :zh_CN=>'zh', :jp=>'jp'
    @current_lang=:en
    assert_equal('en', localized_description(@attr_holder, :name)) 
    assert_equal('', localized_description(nil, :name)) 
    assert_equal('en', localized_description(@attr_holder.name)) 
    @attr_holder.name_en=''
    assert_not_equal('', localized_description(@attr_holder.name)) 
    @current_lang = nil
    assert_equal('zh', localized_description(@attr_holder.name))
  end
end
