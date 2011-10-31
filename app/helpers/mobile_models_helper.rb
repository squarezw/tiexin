module MobileModelsHelper
  def safe_mobile_model_icon(mobile_model)
    mobile_model.picture ? image_tag(mobile_model.picture.url) : image_tag('nopic.jpg')
  end
end
