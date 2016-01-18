class Frontend::ErrorsController < Frontend::FrontendController
  def show
    modify_page_header_variables(@page_header_tags, params[:id]) if @page_header_tags
    
    render_optional_error_file(params[:id])
  end
  
  private
  
  def modify_page_header_variables(page_header_tags_hash, error_id)
    page_header_tags_hash.each do |key, value|
      if value.is_a?(String)
        temp = c_t(".error_#{error_id}") rescue 'An unknown error occured.'
        temp = temp.downcase if key == 'keywords'
        value.gsub!('__ERROR__', temp)
      elsif value.is_a?(Hash)
        modify_page_header_variables(value, error_id)
      end
    end
  end
end