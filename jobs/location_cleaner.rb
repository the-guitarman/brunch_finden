class LocationCleaner 
  include LibForwarding
  
  def run
    bs = GLOBAL_CONFIG[:find_each_batch_size]
    Location.find_each(:batch_size => bs, :conditions => {:published => false}) do |l|
      delete_cache(l)
      source_path = "/#{l.rewrite}.html"
      destination_path = "/#{l.zip_code.city.rewrite}"
      create_forwarding(source_path, destination_path)
    end
  end
  
  private
  
  def delete_cache(location)
    path = "#{location.rewrite}.html"
    file_name = "#{Rails.root}/public/cache/#{path}"
    File.delete(file_name) if File.exist?(file_name)
  end
end