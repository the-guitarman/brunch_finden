class RobotsTxtGenerator
  if Rails.version >= '3.0.0'
    include Rails.application.routes.url_helpers
  else
    include ActionController::UrlWriter
  end
  
  FILE = "#{Rails.root}/public/robots.txt"
  
  def initialize  
    @fec = CustomConfigHandler.instance.frontend_config
    default_url_options[:host] = @fec['DOMAIN']['FULL_NAME']
  end
  
  def run
    text = comments
    text += generate_rules
    text += sidemap_rule
    File.open(FILE, 'w') do |f|
      f.write(text)
    end
    puts "RobotsTxtGenerator - robots.txt generated: #{File.exist?(FILE)}"
  end
  
  private
  
  def additionals
    {
      '*' => {
        'Disallow' => advertising_opportunities_path
      }
    }
  end
  
  # read lines and extract comment lines
  def comments
    comments = []
    if File.exist?(FILE)
      File.open(FILE, 'r') do |f|
        comments = f.readlines
      end
      comments.delete_if{|l| !l.start_with?('#')}
    end
    return comments.join.to_s + "\n"
  end
  
  def generate_rules
    text = ''
    rc = CustomConfigHandler.instance.robots_txt_config
    rc.each do |user_agent, values|
      text += "User-Agent: #{user_agent}\n"
      values.each do |key, value|
        if [String, Integer, Float].any?{|klass| value.is_a?(klass)}
          text += "#{key}: #{value}\n"
        elsif value.is_a?(Array)
          value.each do |v|
            text += "#{key}: #{v}\n"
          end
        end
      end
      if adds = additionals[user_agent]
        adds.each do |key, value|
          text += "#{key}: #{value}\n"
        end
      end
      text += "\n"
    end
    return text
  end
  
  def sidemap_rule
    text = ''
    if File.exist?("#{Rails.root}/public/sitemap_index.xml.gz")
      text = "Sitemap: http://#{@fec['DOMAIN']['FULL_NAME']}/sitemap_index.xml.gz\n\n"
    end
    return text
  end
end