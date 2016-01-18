class PathRequester
  attr_accessor :host, :logger
  
  SLEEP_TIME_BETWEEN_REQUESTS = 0.5
  
  if Rails.version >= '3.0.0'
    include Rails.application.routes.url_helpers
  else
    include ActionController::UrlWriter
  end
  
  include ActionCacheKey
  
  def initialize
    @fec = CustomConfigHandler.instance.frontend_config
    @host = @fec['DOMAIN']['FULL_NAME']
    #@@default_url_options = {:host => @host}
    default_url_options[:host] = @host
    
    @logger = Logger.new(Rails.root.join('log', 'generate_caches_handler.log'), 3, 5*1024*1024)
    
    ActionController::Base.perform_caching = true
  end
  
  def run(path = nil)
    if path
      get(path)
      return
    end
    
    bs = GLOBAL_CONFIG[:find_each_batch_size]
    touched_ptc_ids = []
    PathToCache.find_each({:batch_size => bs}) do |ptc|
      get(ptc.path)
      touched_ptc_ids << ptc.id
      sleep(runtime)
    end
    PathToCache.delete_all({:id => touched_ptc_ids})
  end
  
  def generate_paths
    
  end
  
  def states(conditions = nil)
    
  end
  
  def cities(conditions = nil)
    bs = GLOBAL_CONFIG[:find_each_batch_size]
    City.find_each(:batch_size => bs, :conditions => conditions) do |c|
      file_name = "#{Rails.root}/tmp/cache/views/#{c.rewrite}"
      file_names = ["#{file_name}.cache"]
      if File.directory?(file_name)
        file_names += Dir.glob(file_name+'/*')
      end
      file_names.each do |file_name|
        File.delete(file_name) if File.exist?(file_name)
        puts file_name
      end
      
      limit = (@fec['CITIES']['SHOW']['LIMIT']['LOCATIONS'] || 20 rescue 20)
      count = c.locations.showable.count
      pages = (count.to_f/limit).ceil
      pages = 1 if pages = 0      
      pages.times do |idx|
        
        page = idx + 1
        path = city_rewrite_cache_key(c.rewrite, {:page => (page > 1 ? page : nil)})
        
        #cache_page(path)
        #puts "-- CitySweeper - path: #{path}"
        ptc = PathToCache.find_or_create(path)
        #puts "-- CitySweeper - ptc: #{ptc.errors.inspect}"
        #puts "-- CitySweeper - create_cache_again: #{path}"
        puts app.get(path)
        #get(path)
      end
      
      sleep SLEEP_TIME_BETWEEN_REQUESTS
    end
  end
  
  def locations(conditions = nil)
    bs = GLOBAL_CONFIG[:find_each_batch_size]
    Location.find_each(:batch_size => bs, :conditions => conditions) do |l|
      path = "#{l.rewrite}.html"
      file_name = "#{Rails.root}/public/cache/#{path}"
      File.delete(file_name) if File.exist?(file_name)
      puts file_name
      puts app.get(path)
    end
  end

  private
  
  def get(path)
    start = Time.now
    status = app.get("#{path}")
    runtime = Time.now - start
    log("#{path}, #{status}, #{runtime}s")
  end

  def app
    unless defined?(@@app)
      @@app = ActionController::Integration::Session.new
      @@app.host = host
    end
    return @@app
  end
  
  def log(text)
    logger.info "#{DateTime.now.to_s(:db)}, #{text}"
  end
end