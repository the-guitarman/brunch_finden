module Frontend::SocialPluginLoaderHelper
  def social_plugin_loader(plugin)
    plugin_id = plugin.to_s.to_crc32
    case plugin
    when :facebook_like_box
      link_to(
        'Facebook Like-Box laden', 
        social_url(plugin_id), 
        {:class => 'social-plugin facebook-like-box', :rel => 'nofollow'}
      ).html_safe
    end
  end
end