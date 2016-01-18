module ActionView::Helpers::UrlHelper
  alias_method(:standard_url_for, :url_for)
  # overwrites ActionView::Helpers::UrlHelper.url_for
  # now there is a spezial option +rewrite+, this option generates magicaly
  # an link to the RewriteController.show action.
  #
  # OBSOLETE
  def url_for(options = {})
    if options.is_a? Hash
      mods={:only_path=>false}
#      if options.include?(:rewrite)
#        mods.merge!({:controller=>'/rewrites',:action=>'show'})
#      end
      options=mods.update options
    end
    standard_url_for(options)
  end
  
  alias_method :standard_link_to,:link_to
  # Magic replacement for ActionView::Helpers::UrlHelper.link_to
  # the miracoulus new option +link+ points to a absolute url, ever.
  # when no host is given it assumes that you want to go to your our own host.
  def link_to(name, options = {}, html_options = nil)
    add_rel_nofollow_for_hash_link(options, html_options)
    standard_link_to(name, options, html_options)
  end
  
  private
  
  def add_rel_nofollow_for_hash_link(options, html_options)
    case options.class.name
    when 'Hash'
      if (options and link=options[:link])
        html_options=html_options || {}
        host_with_port=@controller.request.host_with_port
        html_options[:href]=
          if link.include? "://"
          link
        elsif link.include? "/"
          "http://"+host_with_port+link
        else
          "http://"+host_with_port+"/"+link
        end
      end
    when 'String'
      if options == '#'
        if html_options.blank?
          html_options = {:rel => 'nofollow'}
        elsif html_options.is_a?(Hash)
          html_options.symbolize_keys!
          if html_options[:rel].blank?
            html_options[:rel] = 'nofollow'
          elsif not html_options[:rel].to_s.include?('nofollow')
            html_options[:rel] = html_options[:rel].to_s + ' nofollow'
          end
        end
      end
    end
  end
end
