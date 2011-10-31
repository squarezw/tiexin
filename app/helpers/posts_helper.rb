module PostsHelper
  def post_icon(post)
    if post.vote_result == Post::VOTE_GOOD
      icon = 'form/icon_best'
    else
      if post.original
          icon =  'form/icon_org'
          alt = _("Post|Original")
      else
        return ''
      end
    end
    return image_tag("#{icon}.gif", :alt => alt)
  end

  def show_in_homepage_button_label
    return @post.show_in_homepage ? '从首页移除' : '显示在首页'
  end
end
