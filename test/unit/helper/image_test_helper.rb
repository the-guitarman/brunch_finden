# encoding: utf-8

module ImageTestHelper
  
  private
  
  def valid_location_image_parameters(parameters = {})
    {
      :title => 'test', 
      :location_id => 1, 
      :presentation_type => 'location', 
      :status => 'checked', 
      :data_source_id => 1,
      :image_file_url => upload_file_url,
      :general_terms_and_conditions => true
    }.merge(parameters)
  end
  
  def upload_file_url
    return "file://#{Rails.root}/test/data/images/alex_chemnitz.jpg"
  end
end