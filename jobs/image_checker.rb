class ImageChecker
  def run
    delete_all_unpublished_images
  end
  
  private
  
  def delete_all_unpublished_images
    bs = GLOBAL_CONFIG[:find_each_batch_size]
    conditions = [
      "status = ? AND presentation_type = ? AND created_at <= ? and published = ?", 
      LocationImage::NEW_IMAGE_STATE,
      LocationImage::PRESENTATION_TYPES.last,
      Time.now.ago(LocationImage::UNPUBLISHED_VALID_FOR.hours),
      false
    ]
    LocationImage.find_each({:batch_size => bs, :conditions => conditions}) do |li|
      li.destroy
    end
  end
end