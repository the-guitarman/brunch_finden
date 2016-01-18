if Rails::VERSION::MAJOR < 3
  puts '=> Javascript default sources loaded'
  module ActionView::Helpers::AssetTagHelper
    js_default_sources = []
    
    jquery_min = Rails.env.development? ? '' : '.min'
    jquery_sources = Dir.glob("public/javascripts/jquery-[0-9].[0-9].[0-9]#{jquery_min}.js")
    if jquery_sources.length > 0
      js_default_sources << File.basename(jquery_sources.sort{|x,y| y <=> x}.first)
    else
      raise 'No jquery source files found!'
    end
    
    js_default_sources << 'rails.js'
    
    remove_const :JAVASCRIPT_DEFAULT_SOURCES
    JAVASCRIPT_DEFAULT_SOURCES = js_default_sources

    reset_javascript_include_default
  end
end