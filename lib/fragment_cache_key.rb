module FragmentCacheKey
  def self.included(klass)
    klass.instance_eval do
      #extend ClassMethods
      include InstanceMethods
      
      if klass.name.start_with?('Frontend::Frontend') or 
         klass.name.start_with?('Mobile::Mobile')
        helper_method :frontend_index_locations, :frontend_index_ct_states,
          :frontend_index_ct_latest_reviews, :frontend_index_ct_city_with_most_locations,
          :frontend_index_ct_latest_locations, :frontend_index_ct_latest_coupons,
          
          :mobile_index_ct_states
      end
    end
  end
  
  module InstanceMethods
    def frontend_index_locations(version = '1')
      "frontend_index_locations-#{Rails.env}-#{version}"
    end
    
    def frontend_index_ct_states(version = '1')
      "frontend_index_ct_states-#{version}"
    end
    
    def frontend_index_ct_city_with_most_locations(version = '1')
      "frontend_index_ct_city_with_most_locations-#{version}"
    end
    
    def frontend_index_ct_latest_locations(version = '1')
      "frontend_index_ct_latest_locations-#{version}"
    end
    
    def frontend_index_ct_latest_reviews(version = '1')
      "frontend_index_ct_latest_reviews-#{version}"
    end
    
    def frontend_index_ct_latest_coupons(version = '1')
      "frontend_index_ct_latest_coupons-#{version}"
    end
    
    def mobile_index_ct_states(version = '1')
      "mobile_index_ct_states-#{version}"
    end
  end
end