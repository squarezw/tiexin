module PhotoOwner
  def random_photo
    photo_size = self.photos.count
    if photo_size > 0
      idx = rand(photo_size)
      return self.photos.find(:all, :offset=>idx, :limit=>1)[0]
    else
      return nil
    end
  end
end