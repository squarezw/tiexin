class RemoteLinkRenderer < WillPaginate::LinkRenderer
  def prepare(collection, options, template)
    @remote = options.delete(:remote) || {}
    @method = options.delete(:method) || :post
    super
  end

protected
  def page_link(page, text, attributes = {})
    @template.link_to_remote(text, {:url => url_for(page), :method => @method}.merge(@remote))
  end
end