module RewriteRoutes
  def self.included(klass)
    klass.instance_eval do
      #extend ClassMethods
      include InstanceMethods
      
      if klass.name.start_with?('Frontend::Frontend') or 
         klass.name.start_with?('Mobile::Mobile')
        helper_method :create_rewrite_hash
      end
    end
  end
  
  module InstanceMethods
    def create_rewrite_hash(rewrite)
      url_elements = [:state, :city, :location]
      ret = {}
      array = rewrite.split('/')
      array.each_with_index do |el, index|
        ret[url_elements[index]] = el
      end
      return ret
    end
  end
end