module BlogsHelper
  def safe_blog_banner_url(blog)
    blog.picture ? blog.picture.normal.url : '/themes/standard/images/header.jpg'
  end 
end
