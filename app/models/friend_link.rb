class FriendLink < ActiveRecord::Base
  VendorType = ["home","blog","forum"]

  belongs_to :channel

  image_column :pic, :validate_integrity=>false, :versions=> {:logo=>'88x31'}

  validates_presence_of :title
  validates_presence_of :link
end
