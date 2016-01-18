#module ActionView::Helpers::AssetTagHelper
#
#
#  alias_method("orig_js_include_tag", "javascript_include_tag")
#
#  def javascript_include_tag(*sources)
#    options=sources.extract_options!
#    real_sources=expand_js_sources(sources)
#    sources=[real_sources,options].flatten
#    orig_js_include_tag(*sources)
#  end
#
#  #You can let a string end with a / and becomes an js include of all files
#  #inside of that directory.
#  #The former behavior shold be the same as before modifications, if not it's likely a bug.
#  def expand_js_sources(sources)
#    sources.flatten.collect do |source|
#      if source.respond_to?('ends_with?') and source.ends_with?("/")
#        source = Dir[File.join((config.javascripts_dir||config.assets_dir)+"/"+source, '*.js')].collect do |file| 
#          source+File.basename(file).gsub(/\.\w+$/, '')
#        end.sort
#      end
#      source
#    end
#  end
#end

module ActionView::Helpers::AssetTagHelper


  alias_method("orig_js_include_tag", "javascript_include_tag")

  def javascript_include_tag(*sources)
    options=sources.extract_options!
    real_sources=expand_js_sources(sources)
    sources=[real_sources,options].flatten
    orig_js_include_tag(*sources)
  end

  #You can let a string end with a / and becomes an js include of all files
  #inside of that directory.
  #The former behavior shold be the same as before modifications, if not it's likely a bug.
  def expand_js_sources(sources)
    sources.flatten.collect do |source|
      if source.respond_to?('ends_with?') and source.ends_with?("/")
        source = Dir[File.join(JAVASCRIPTS_DIR+"/"+source, '*.js')].collect do
          |file| source+File.basename(file).gsub(/\.\w+$/, '')
        end.sort
      end
      source
    end
  end
end