class Frontend::CommonController < Frontend::FrontendController
  include Frontend::YacaphHelper
  
  #skip_before_filter :set_page_header_tag_configurator, :set_page_header_tags, 
  #  :only => [:captcha]
  
  def captcha
    render({:partial => 'frontend/common/captcha'})
  end
end