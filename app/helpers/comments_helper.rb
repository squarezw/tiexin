module CommentsHelper 
  def commentable_type(commentable)
    commentable.class.to_s.underscore
  end
  
  def commentable_label(commentable)
    if commentable.respond_to? :name
      return localized_description(commentable.name)
    elsif commentable.respond_to? :title
      return commentable.send(:title)
    elsif commentable.respond_to? :subject
      return commentable.send(:subject)
    else
      return commentable.to_s
    end
  end
  
  def show_commentable_path(commentable)
    return '' if commentable.nil?
    if commentable.is_a? Product
      return product_path(class_name_for_url(commentable.vendor), commentable.vendor, commentable)
    elsif commentable.is_a? Post
      return forum_post_path(commentable.forum, commentable)
    else
      "/#{commentable.class.to_s.underscore}s/#{commentable.id}"
    end
  end
  
  def can_vote?(comment)
    return comment.can_vote_by?(@current_user)
  end
  
  def humanize_commentable_type(commentable)
    _(commentable.class.to_s.underscore.humanize.downcase) 
  end
   
  def class_for_owner_commented(comment)
    comment.owner_commented? ? 'owner_commented' : 'normal_comment'
  end
end
