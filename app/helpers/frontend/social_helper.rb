#encoding: utf-8

module Frontend::SocialHelper
  SOCIAL_BOOKMARKS = [:facebook, :twitter, :google_plusone_share, :print, :compact]
  SOCIAL_BOOKMARKS_COMMUNITYBAR = [:facebook, :twitter, :google_plusone_share, :print, :expanded]
  SOCIAL_LINKS = {
    :facebook => 'https://www.facebook.com/pages/brunch-findende/131669423571599', 
    :twitter  => 'https://twitter.com/brunchfinden', 
    #:google_plusone_share => 'https://plus.google.com/106364036396741404778/about/p/pub'
    :google_plusone_share => 'https://plus.google.com/106364036396741404778?rel=author'
  }

  def social_bookmark(name, size = 26)
    #content = image_tag(
    #  "/images/frontend/social/icon_#{name}_#{size}x#{size}.png",
    #  {:class => "social_icon_#{size}", :alt => name, :width => size, :height => size }
    #)
    content = ''
    return link_to(
      content.html_safe,
      '#',
      {:class => "bg-image at-button at-#{size} addthis_button_#{name}"}
    ).html_safe
  end

  def all_social_bookmarks(size = 26, type = 'other')
    if type == 'communitybar'
      return SOCIAL_BOOKMARKS_COMMUNITYBAR.map{|sb| social_bookmark(sb, size)}.join.html_safe
    else
      return SOCIAL_BOOKMARKS.map{|sb| social_bookmark(sb, size)}.join.html_safe
    end
  end
  
  def print_and_compact_bookmarks(size = 26, type = 'other')
    return [:print, :compact].map{|sb| social_bookmark(sb, size)}.join.html_safe
  end

  def social_link(name, link, size = 26)
    #content = image_tag(
    #  "/images/frontend/social/icon_#{name}_#{size}x#{size}.png",
    #  {:class => "social_icon_#{size}", :alt => name, :width => size, :height => size }
    #)
    content = ''
    return link_to(
      content.html_safe,
      link,
      {:class => "bg-image sl-button sl-#{size} social-link-#{name}", :target => :_blank}
    ).html_safe
  end
  
  def all_social_links(size = 26)
    return SOCIAL_LINKS.map{|name, link| social_link(name, link, size)}.join.html_safe
  end
end