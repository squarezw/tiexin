class OperationLog < ActiveRecord::Base
  belongs_to :related_object, :polymorphic=>true 
  belongs_to :member
  serialize :message_parameters
  
  def self.per_page
    20
  end
  
  def message
    return '' unless message_key
    params = Hash.new
    if self.message_parameters
      self.message_parameters.each_pair { |key, value| params[key]= _(value) }
    end
    puts params
    _(self.message_key) % params
  end
end
