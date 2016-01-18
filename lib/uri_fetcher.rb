# Fetch a File from filesystem, FTP or HTTP
require 'net/http'
require 'net/ftp'
require 'cgi'

require 'fileutils'
require 'ftools'

class URIFetcher

  MAXIMUM_REDIRECTIONS = 10

  class DownloadError < StandardError; end

  def self.get_original_host(url)
    invalid_hosts = ['klick.affiliwelt.net', 'ssl.kundenserver.de',
                     'www.denic.de', 'shop1.o2online.de', 'clicks.pangora.com',
                     'www.belboon.com', 'ad.zanox.com', 'www.affili.net',
                     'partners.webmasterplan.com', 'www.zanox-affiliate.de',
                     'shop.strato.de', 'www.afterbuy.de', 'adfarm.mediaplex.com']
    @origin_url = ''
    return false unless parsed_url = URI.parse(url)
    url = "http://#{url}" unless parsed_url.scheme
    return false unless URIFetcher::set_original_url(url)
    return false unless parsed_url = URI.parse(@origin_url)
    return false unless parsed_url.host
    return false if invalid_hosts.include?(parsed_url.host.downcase)
    parsed_url.host.downcase
  rescue Exception => e
    false
  end

  def self.complete_uri(uri, scheme = 'http')
    ret = uri
    begin
      parsed_uri = URI.parse(uri)
      ret = scheme + '://' + uri unless parsed_uri.scheme
    rescue
      ret = uri
    end
    return ret
  end

  def self.validate_uri(uri, valid_schemes = false)
    valid_schemes = ['http', 'https', 'ftp'] unless valid_schemes
    begin
      parsed_uri = URI.parse(uri)
    rescue
      return false
    end
    return false unless parsed_uri.scheme
    return false unless valid_schemes.include?(parsed_uri.scheme)
    true
  end

  private

  def download
    dirs = [File.dirname(@temp_file_name), File.dirname(@dest_file_name)]
    dirs.each do |dir|
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
    end

    @filesize = 0
    case @uri.scheme
    when "http", "https" then from_http(@uri, MAXIMUM_REDIRECTIONS)
    when "ftp" then from_ftp
    when "file" then from_file
    else
      raise URI::InvalidURIError
    end
  end

  def unzip
    raise DownloadError, "No file downloaded" unless File.exist?(@temp_file_name)
    ft=File.mimetype(@temp_file_name).strip
    #p "FILE TYPE: #{ft}"
    case ft
    when 'application/zip' then `unzip -p #{@temp_file_name} > #{@dest_file_name}`
    when 'application/x-gzip' then `gzip -cd #{@temp_file_name} > #{@dest_file_name}`
    else File.copy(@temp_file_name,@dest_file_name)
    end
    raise DownloadError, "File has zero size" unless File.size?(@dest_file_name)
  end

  def from_http(uri, limit = 10)
    raise DownloadError, 'HTTP redirect too deep' if limit == 0

#      response = Net::HTTP.get_response(URI.parse(uri_str))
    response = nil
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'
    http.start do |http2|
      request=Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth(uri.user, CGI::unescape(uri.password)) unless uri.user.blank?
      response=http2.request(request)
      if response.class == Net::HTTPUnauthorized and uri.user.blank? == false
        request.digest_auth(uri.user, uri.password, response)
        response=http2.request(request)
      end

#        puts "Status: #{response.code}"
      case response
      when Net::HTTPSuccess
        save response.body
      when Net::HTTPRedirection
        uri = URI.parse(response['location'])
        from_http(uri, limit - 1)
      else
        raise DownloadError, "got #{response.code} - #{response.message}"
      end
    end
  rescue EOFError => e
#    puts "uri_str #{uri.request_uri}"
#    puts "limit #{limit}"
#    puts "response: #{response.inspect}"
    raise DownloadError, "Error after redirect #{11-limit}"
  rescue Timeout::Error => e
    raise DownloadError, "Timeout"
  end

  def from_ftp
    Net::FTP.open(@uri.host, @uri.user, CGI::unescape(@uri.password)) do |ftp|
      #ftp.login
      ftp.getbinaryfile(@uri.path, @temp_file_name, 1024)
      ftp.close
    end
  end

  def from_file
    File.copy(@uri.path, @temp_file_name)
  end

  def save(data)
    File.open(@temp_file_name, 'w') {|f| f.write(data)} if data
    if File.exist?(@temp_file_name)
      @filesize = File.size?(@temp_file_name)
    end
  end

  def self.set_original_url(url, limit = 10)
    return false if limit == 0
    return false unless parsed_url = URI.parse(url)
    @origin_url = url
    response = Net::HTTP.get_response(parsed_url)
    case response
    when Net::HTTPRedirection then
      location = response['location']
      location = location.slice(1, location.length) if location.slice(0, 1) == '.'
      parsed_location = URI.parse(location)
      @origin_url = location
      unless parsed_location.scheme
        @origin_url = "/#{@origin_url}" if @origin_url.slice(0, 1) != '/'
        @origin_url = "#{parsed_url.scheme}://#{parsed_url.host}#{@origin_url}"
      end
      URIFetcher::set_original_url(@origin_url, limit - 1)
    when Net::HTTPSuccess     then
      meta_refresh = URIFetcher::get_redirection_meta_refresh(response, parsed_url)
      URIFetcher::set_original_url(meta_refresh, limit - 1) if meta_refresh
    else
#      puts "Response ERROR: #{response.error}"
      false
    end
    true
  rescue Exception => e
#    puts "Exeption ERROR: #{e.message}"
    false
  end

  def self.get_redirection_meta_refresh(response, url)
    refresh_url = false
    body = response.body
    html_doc = Nokogiri::HTML(body)
    html_doc.xpath('//head/meta').each do |node|
      if node.keys && node.keys.include?('http-equiv') && node.keys.include?('content')
        http_equiv_index = node.keys.find_index('http-equiv')
        content_index = node.keys.find_index('content')
        if node.values && node.values[http_equiv_index] && node.values[http_equiv_index].downcase == 'refresh'
          if node.values[content_index]
            parts = node.values[content_index].split(';')
            parts.each do |part|
              part.strip!
              if part.downcase.scan(/url=/).include?('url=')
                refresh_url = part.gsub(/url=/, '')
                refresh_url = refresh_url.gsub(/URL=/, '')
                refresh_url = "/#{refresh_url}" if refresh_url.slice(0, 1) != '/'
              end
            end
          end
        end
      end
    end
    if refresh_url
      check_url = URI.parse(refresh_url)
      unless check_url.scheme
        refresh_url = "#{url.scheme}://#{url.host}#{refresh_url}"
      end
    end
    refresh_url
  end

end
