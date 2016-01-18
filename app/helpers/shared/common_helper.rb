#encoding: utf-8

module Shared::CommonHelper
  # Returns an anchor link tag. Content is the link content (HTML) and 
  # anchor is the anchor name (String).
  def anchor_for(content, anchor)
    #link_to(content.html_safe, {}, {:name => anchor}).html_safe
    "<a class='anchor' name='#{anchor}'>#{content}</a>".html_safe
  end
end