module ArticlesHelper
  def articles_page_title
    page_title = h(@member.nick_name)
    page_title << " -- h(@folder.name)" if @folder
    if @article
      page_title << " -- h(@article.subject)" 
    else
      page_title << ' -- '
      page_title << _('Articles')
    end
    page_title
  end
  
  def articles_to_rss_items(xml, articles)
    articles.each do |article|
      xml.item do
        xml.title(article.subject)
        xml.link(member_article_url(article.member, article))
        xml.description { xml.cdata!(replace_newline(bbcodeize(article.content))) }
        xml.author(article.member.nick_name)  
        xml.comments(member_article_url(article.member, article))
        xml.guid(member_article_url(article.member, article), :isPermalink=>true)
        xml.pubDate(article.updated_at.rfc822)
        xml.source(formatted_member_url(article.member, :rss))
      end
    end
  end
end
