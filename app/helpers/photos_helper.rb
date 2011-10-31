module PhotosHelper                    
  def owner_type(owner)
    owner.class.to_s.underscore
  end
  
  def class_for_merchant_uploaded(photo)
    if photo.owner_uploaded?
      'owner_uploaded'
    else
      ''
    end
  end

  def photo_owner_path(owner)
    if owner.is_a? Gift
      return campaign_gift_path(owner)
    else
      return owner
    end
  end
  
  def photo_owner_name(owner)
    name = owner.name
    return '' if name.nil?
    if name.respond_to?(@current_lang.to_sym) 
      return h(name.send(@current_lang.to_sym))
    else
      return h(name)
    end
  end
end
