(Promotion.find :all).each do |pro|
  if pro.banner
    pro.post = File.new(pro.banner.path)
    pro.banner = nil
    pro.save_with_validation false
  end
end