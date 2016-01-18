module Shared::ShowMoreLessLinkHelper
  def show_more_less_link(text, length=100)
    ret = ''
    show_text = truncate(text, {:length => length, :separator => ' ', :omission => ''})
    ret += show_text
    more_text = text.gsub(show_text, '')
    unless more_text.blank?
      ret += '<span class="more-text" style="display:none;">' + more_text + '</span>'
      ret += ' ('
      ret += link_to("<span>#{t('shared.read_more_text')}</span>", '#', {:class => 'more-link', :rel => 'moreText'})
      ret += ')'
    end
    return ret
  end
end