#encoding: utf-8
require 'test_helper'

require 'unit/helper/image_test_helper'

class LocationImageTest < ActiveSupport::TestCase
  include ImageTestHelper
  
  def test_create
    img = LocationImage.create(valid_location_image_parameters)
    assert img.valid?
    assert !img.published
    assert img.confirmation_code?
    img2 = LocationImage.find(:first, :conditions => ['title=?', 'test'])
    assert_equal img, img2#,errors_msg(img)
  end
  
  def test_validations
    img = LocationImage.new
    assert !img.valid?
    img = LocationImage.new(:presentation_type => 'location')
    assert !img.valid?    
    #prod = Product.new(:name => 'test location', :data_source_id => 1)
    img = LocationImage.new(:location_id => 1, :presentation_type => 'Hallo')
    assert !img.valid?
    assert img.errors[:general_terms_and_conditions].any?
    img = LocationImage.new(:location_id => 1, :presentation_type => 'location', 
      :status => "new",:data_source_id=>1, :image_file_url => upload_file_url,
      :general_terms_and_conditions => true
    )
    assert img.valid?#,errors_msg(img)
    assert !img.errors[:general_terms_and_conditions].any?
    img = LocationImage.new(:location_id => 1, :presentation_type => 'result', 
      :status => "new",:data_source_id=>1, :image_file_url => upload_file_url,
      :general_terms_and_conditions => true
    )
    assert img.valid?#,errors_msg(img)
    img = LocationImage.new(:location_id => 1, :presentation_type => 'location', 
      :status => "new",:data_source_id => 1, :image_file_url => upload_file_url,
      :is_main_image => true,
      :general_terms_and_conditions => true
    )  
    assert img.valid?
    img.uploader_denied_main_image = true
    assert !img.valid?
  end
  
  def test_touch_associated_after_destroy
    # Init
    review = Review.first
    assert_equal review.destination_type, 'Location'
    location = review.destination
    
    img = LocationImage.new(valid_location_image_parameters)
    img.location_id = location.id
    img.frontend_user_id = review.frontend_user.id
    assert img.save
    
    review.reload
    location.reload   
    review_updated_at = review.updated_at
    location_updated_at = location.updated_at
    
    sleep(2)
    
    # Destroy image
    img.destroy
    review.reload
    location.reload

    # Check
    assert review.updated_at > review_updated_at
    assert location.updated_at > location_updated_at
  end

  def test_modules_and_constants
    # modules
    assert LocationImage.included_modules.include?(Mixins::ImageCacheSweeper)
    
    # constants
    if Rails.version >= '3.0.0'
      assert LocationImage.constants.include?(:IMAGE_DIRECTORY)
    else
      assert LocationImage.constants.include?('IMAGE_DIRECTORY')
    end
    assert_equal 'public/system/originals/location_images', LocationImage::IMAGE_DIRECTORY
    
    if Rails.version >= '3.0.0'
      assert LocationImage.constants.include?(:PRESENTATION_TYPES)
    else
      assert LocationImage.constants.include?('PRESENTATION_TYPES')
    end
    assert LocationImage::PRESENTATION_TYPES.is_a?(Array)
    assert_equal 2, LocationImage::PRESENTATION_TYPES.length
    assert_equal 'location', LocationImage::PRESENTATION_TYPES.first
    assert_equal 'result', LocationImage::PRESENTATION_TYPES.last
    
    if Rails.version >= '3.0.0'
      assert LocationImage.constants.include?(:IMAGE_STATES)
    else
      assert LocationImage.constants.include?('IMAGE_STATES')
    end
    assert LocationImage::IMAGE_STATES.is_a?(Array)
    assert_equal 2, LocationImage::IMAGE_STATES.length
    assert LocationImage::IMAGE_STATES.include?('new')
    assert LocationImage::IMAGE_STATES.include?('checked')
    
    if Rails.version >= '3.0.0'
      assert LocationImage.constants.include?(:IMAGE_RENDER_SIZES)
    else
      assert LocationImage.constants.include?('IMAGE_RENDER_SIZES')
    end
    assert LocationImage::IMAGE_RENDER_SIZES.is_a?(Hash)
    assert_equal 3, LocationImage::IMAGE_RENDER_SIZES.keys.length
    
    assert LocationImage::IMAGE_RENDER_SIZES.keys.include?(:list)
    assert_equal '75x75', LocationImage::IMAGE_RENDER_SIZES[:list]
    assert LocationImage::IMAGE_RENDER_SIZES.keys.include?(:location)
    assert_equal '230x230', LocationImage::IMAGE_RENDER_SIZES[:location]
    assert LocationImage::IMAGE_RENDER_SIZES.keys.include?(:fancybox)
    assert_equal '800x600', LocationImage::IMAGE_RENDER_SIZES[:fancybox]
    
    if Rails.version >= '3.0.0'
      assert LocationImage.constants.include?(:IMAGE_CACHE_FORMAT)
    else
      assert LocationImage.constants.include?('IMAGE_CACHE_FORMAT')
    end
    assert LocationImage::IMAGE_CACHE_FORMAT.is_a?(Symbol)
    assert_equal :png, LocationImage::IMAGE_CACHE_FORMAT
    
    if Rails.version >= '3.0.0'
      assert LocationImage.constants.include?(:MINIMUM_UPLOAD_SIZE)
    else
      assert LocationImage.constants.include?('MINIMUM_UPLOAD_SIZE')
    end
    assert LocationImage::MINIMUM_UPLOAD_SIZE.is_a?(Fixnum)
    assert_equal 100, LocationImage::MINIMUM_UPLOAD_SIZE
    
    if Rails.version >= '3.0.0'
      assert LocationImage.constants.include?(:NO_IMAGE)
    else
      assert LocationImage.constants.include?('NO_IMAGE')
    end
    assert LocationImage::NO_IMAGE.is_a?(String)
    assert_equal 'no_location_image.png', LocationImage::NO_IMAGE
  end
  
  def test_select_a_new_main_image_after_destroy_main_image
    LocationImage.delete_all
    
    img1 = LocationImage.create(
      valid_location_image_parameters({
        :location_id => 1, 
        :is_main_image => true,
        :uploader_denied_main_image => false
      })
    )
    assert img1.valid?
    img2 = LocationImage.create(
      valid_location_image_parameters({
        :location_id => 1, 
        :is_main_image => false,
        :uploader_denied_main_image => false
      })
    )
    assert img2.valid?
    
    main_image = LocationImage.find(:first, {:conditions => {:is_main_image => true}})
    assert_not_nil main_image
    assert_equal img1, main_image
    
    img1.destroy
    assert img1.frozen?
    
    main_image = LocationImage.find(:first, {:conditions => {:is_main_image => true}})
    assert_not_nil main_image
    assert_equal img2, main_image
  end
  
  def test_can_not_select_a_new_main_image_after_destroy_main_image
    LocationImage.delete_all
    
    img1 = LocationImage.create(
      valid_location_image_parameters({
        :location_id => 1, 
        :is_main_image => true,
        :uploader_denied_main_image => false
      })
    )
    assert img1.valid?
    img2 = LocationImage.create(
      valid_location_image_parameters({
        :location_id => 1, 
        :is_main_image => false,
        :uploader_denied_main_image => true
      })
    )
    assert img2.valid?
    
    main_image = LocationImage.find(:first, {:conditions => {:is_main_image => true}})
    assert_not_nil main_image
    assert_equal img1, main_image
    
    img1.destroy
    assert img1.frozen?
    
    main_image = LocationImage.find(:first, {:conditions => {:is_main_image => true}})
    assert_nil main_image
  end
end
