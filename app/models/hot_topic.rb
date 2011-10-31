class HotTopic < ActiveRecord::Base
  validates_format_of :link, :with => /^(http|https):\/\/[A-Za-z0-9]+\.[A-Za-z0-9]+[\/=\?%\-&_~`@[\]\':+!]*([^\"\"])*$/, :message => "ex: http://www.tiexin.com"
end
