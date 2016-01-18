if Rails.version < '3.1.0'
  puts "== INIT: Rack::Response Patch (for Rack Servers only [Puma, Unicorn])"
  class Rack::Response
    def close
      @body.close if @body.respond_to?(:close)
    end
  end
end