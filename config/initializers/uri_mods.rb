#encoding: UTF-8
module URI
  def self.clean_up(uri)
    return nil unless uri
    uri.gsub!(':\\\\', '://') if uri.include?(':\\\\')
    uri.gsub!('\\', '') if uri.include?('\\')
    uri.gsub!('z.B. ', '') if uri.include?('z.B. ')

    value_unescaped = self.unescape(uri)
    value_unescaped.strip!
    value_unescaped.gsub!("\t", '') if value_unescaped.include?("\t")
    value_unescaped.gsub!('[', CGI.escape('[')) if value_unescaped.include?('[')
    value_unescaped.gsub!(']', CGI.escape(']')) if value_unescaped.include?(']')
    value_unescaped.gsub!('{', URI.escape('{')) if value_unescaped.include?('{')
    value_unescaped.gsub!('}', URI.escape('}')) if value_unescaped.include?('}')
    value_unescaped.gsub!(' ', URI.escape(' ')) if value_unescaped.include?(' ')
    value_unescaped.gsub!('�', URI.escape('�')) if value_unescaped.include?('�')
    value_unescaped.gsub!('|', URI.escape('|')) if value_unescaped.include?('|')

    running = 0
    begin
      url = self.parse(value_unescaped)
      request_uri = url.request_uri
      unless request_uri.blank?
        request_uri.gsub!('//', '/') if request_uri.include?('//')
        request_uri.gsub!(/\/+$/, '') if request_uri.end_with?('/')
      end
      value_unescaped = url.to_s
    rescue
      if running == 0
        a = URI.extract(value_unescaped)
        unless a.empty?
          value_unescaped = a.first
          running += 1
          retry
        end
      end
    end

    value_unescaped
  end

  # Checks wether the url exists.
  # Usage: URI.exist?('http://www.domain.de') will return true.
  def self.exist?(url)
    ret = false
	  url = URI.parse(url)
	  begin
	    Net::HTTP.start(url.host, url.port) do |http|
	      # An dieser Stelle kann bei Bedarf auch auf
	      # andere Response-Codes geprüft werden
        code = http.head(url.request_uri).code.to_i
        ret = code >= 200 and code < 400 or [401, 402].include?(code)
	    end
	  rescue SocketError => se
	    # Fehlerbehandlung, wenn die Domain nicht existiert
	    # Je nach Applikation kann hier die entsprechende Aktion durchgeführt werden
	  rescue
	    # Alle anderen Fehlerfälle werden/können hier behandelt werden
	  end
    return ret
	end

  def self.parse_escape(uri)
    self.parse(self.escape(uri))
  end

end
