class Blog < ActiveRecord::Base
#  has_many :articles, :dependent=>:nullify
#  has_many :folders, :dependent=>:destroy
  belongs_to :owner, :class_name => 'Member', :foreign_key => :owner_id
  has_many :rss_sources, :dependent=>:destroy
  has_many :visitors, :class_name => 'BlogAccessLog', :dependent=>:delete_all, :order=>'id desc', :select => "distinct(member_id)"
    
  SkinType = [
    [ _("Standard"), 1 ]
  ]
  validates_presence_of :simple_name, :name
  validates_length_of :simple_name, :within => 1..30, :allow_nil=>true
  validates_length_of :name, :within => 1..30,  :allow_nil=>true
  validates_format_of :simple_name, :with=>/^([_\-.A-z0-9]*)$/ , :allow_nil=>true
  validates_uniqueness_of :simple_name, :allow_nil=>true


  image_column :picture, :validate_integrity=>false,
               :store_dir => 
                    proc { |inst, attr| 
                      time = inst.created_at.nil? ? Time.now : inst.created_at
                      File.join(time.year.to_s, time.month.to_s, time.day.to_s,
                        ActiveSupport::Inflector.underscore(inst.class).to_s, attr.to_s, inst.id.to_s)
                    },
                :versions=> {:small=>'465x80', :normal=>'930x160'}
            
  def self.most_active_blog_author(limit=10)
    return Article.connection.select_all('select member_id, count(*) cnt from articles group by member_id order by cnt desc limit 10').collect{ |row| Member.find row['member_id']}
  end
  
  def self.most_popular_blog(limit=10)
    return self.find :all, :order=>'read_times desc', :limit=>limit
  end
  
  def read!
    update_attribute_with_validation_skipping :read_times, self.read_times + 1
  end
  
  def latest_comments(limit = 5)
     Comment.find_by_sql("select * from comments where commentable_id in (select id from articles where member_id = #{self.owner.id}) order by created_at desc limit #{limit} ")
  end
  
  def url
    "http://#{self.simple_name}.blog.#{XNavi::SITE_DOMAIN_NAME}"
  end
end
