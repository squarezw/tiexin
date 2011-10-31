class SearchLog < ActiveRecord::Base
  belongs_to :city
  belongs_to :member
end
