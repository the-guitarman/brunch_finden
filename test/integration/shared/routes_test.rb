require 'test_helper'

class Shared::RoutesTest < ActionController::IntegrationTest
  def test_images_routes
    #paths to images (YOPI_CONFI[:location_images_cache_dir]):
    # match '/location_images/:id_sub_dir/:id/:size.:format', 
    #  :to => 'shared/images#get_image'
    assert_routing_with_host(
      {:path => '/location_images/0/5/large.jpg'},
      {
        :controller => 'shared/images', :action => 'get_location_image',
        :id_sub_dir => '0', :id => '5', :size => 'large', :format => 'jpg',
        :namespace => nil, :subdomains => ['www']
      },
      'www.example.com'
    )
#    assert_recognizes_with_host(
#      {
#        :controller => 'shared/images', :action => 'get_location_image',
#        :id_sub_dir => '0', :id => '5', :size => 'large', :format => 'jpg',
#        :namespace => nil, :subdomains => ['www']
#      },
#      {:path => '/location_images/0/5/large.jpg', :host => 'www.example.com'}
#    )
#    assert_generates_with_host(
#      '/location_images/0/5/large.jpg',
#      {
#        :controller => 'shared/images', :action => 'get_location_image',
#        :id_sub_dir => '0', :id => '5', :size => 'large', :format => 'jpg',
#        :namespace => nil, :subdomains => ['www']
#      },
#      'www.example.com'
#    )

    #rewrite for development mode:
    # match '/product_images/:id_sub_dir/:id/:size/:seo_name.:format', 
    #  :to => 'shared/images#get_image'
    assert_routing_with_host(
      {:path => '/location_images/0/5/large/seoname.jpg'},
      {
        :controller => 'shared/images', :action => 'get_location_image',
        :id_sub_dir => '0', :id => '5', :size => 'large',
        :seo_name => 'seoname', :format => 'jpg',
        :namespace => nil, :subdomains => ['www']
      },
      'www.example.com'
    )
  end
end