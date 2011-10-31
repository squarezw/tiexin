module OperationLogsHelper
  def object_type(obj)
    obj.class.to_s.underscore
  end
  
  def related_object_to_string(obj)
    return '' unless obj
    if obj.is_a? Reply
      return _('Reply To %{post}') % { :post=>obj.post.title }
    end
    attr_name = [:name, :title, :subject].find { |a| obj.respond_to?(a) and !obj.send(a).nil? }
    return retrieve_identity_attr(obj, attr_name) if attr_name
  end
  
  def retrieve_identity_attr(obj, attr_name)
    attr_value = obj.send attr_name
    if attr_value.respond_to? :all_lang
      return h(localized_description(obj, attr_name))
    else
      _(attr_value.to_s)
    end
  end

end
