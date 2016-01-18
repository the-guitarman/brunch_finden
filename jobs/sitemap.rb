require 'sitemap_generator'

include RewriteRoutes

class ProjectSitemap
  def run
    fec = CustomConfigHandler.instance.frontend_config
    SitemapGenerator::Sitemap.default_host = "http://#{fec['DOMAIN']['FULL_NAME']}"
    SitemapGenerator::Sitemap.include_index = true
    SitemapGenerator::Sitemap.include_root = true
    
    SitemapGenerator::Sitemap.create do
      default_url_options[:host] = fec['DOMAIN']['FULL_NAME']
      
#      group({
#        :default_host  => "http://#{fec['DOMAIN']['FULL_NAME']}",
#        :include_index => true,
#        :include_root  => true
#      }) do
        CouponCategory.showable.find_each({
          :select => 'id, rewrite, updated_at', 
          :batch_size => ::GLOBAL_CONFIG[:find_each_batch_size]
        }) do |cc|
          add(coupon_category_path(cc.rewrite), {
            :changefreq => 'daily',
            :lastmod => cc.updated_at,
            :priority => 1.0
          })
        end

        Location.showable.find_each({
          :select => 'id, rewrite, updated_at', 
          :batch_size => ::GLOBAL_CONFIG[:find_each_batch_size]
        }) do |l|
          add(location_rewrite_path(create_rewrite_hash(l.rewrite)), {
            :changefreq => 'monthly',
            :lastmod => l.updated_at,
            :priority => 1.0
          })
        end

        City.find_each({
          :select => 'id, rewrite, updated_at', 
          :conditions => 'number_of_locations > 0',
          :batch_size => ::GLOBAL_CONFIG[:find_each_batch_size]
        }) do |c|
          add(city_rewrite_path(create_rewrite_hash(c.rewrite)), {
            :changefreq => 'monthly',
            :lastmod => c.updated_at,
            :priority => 0.8
          })
        end

        State.find_each({
          :select => 'id, rewrite, updated_at', 
          :conditions => 'number_of_locations > 0',
          :batch_size => ::GLOBAL_CONFIG[:find_each_batch_size]
        }) do |s|
          add(state_rewrite_path(create_rewrite_hash(s.rewrite)), {
            :changefreq => 'monthly',
            :lastmod => s.updated_at,
            :priority => 0.7
          })
        end

        add '/neue-brunch-location-vorschlagen.html', :changefreq => 'monthly', :priority => 0.6
        add '/neue-brunch-location-eintragen.html', :changefreq => 'monthly', :priority => 0.6
        add '/ueber-uns.html', :changefreq => 'yearly', :priority => 0.5
        add '/impressum.html', :changefreq => 'yearly', :priority => 0.5
        add '/agb.html', :changefreq => 'yearly', :priority => 0.5
        add '/datenschutz.html', :changefreq => 'yearly', :priority => 0.5
#      end
    end

    if Rails.env.production?
      # called for you when you use the rake task
      SitemapGenerator::Sitemap.ping_search_engines
    end
  end
end
