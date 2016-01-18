#encoding: utf-8
require 'test_helper'

class Frontend::LocationImagesControllerTest < ActionController::TestCase
#  fixtures :location_images
#
#  # process before each test method
#  def setup
#    
#  end
#
#  # process after each test method
#  def teardown
#
#  end

  def test_new
    get :new, {
      :state    => 'sachsen',
      :city     => 'chemnitz', 
      :location => 'alex-chemnitz'
    }
    assert_response :success
    assert_template 'frontend/location_images/new'
    assert_select 'head' do
      assert_select 'title', 'Ein Bild zu ALEX Chemnitz (Sachsen) hochladen - www.example.com'
      assert_select 'meta[name=robots][content="index,follow"]', 1
    end
    assert_select 'body' do
      
    end
    
    
    xhr :get, :new, {
      :state    => 'sachsen',
      :city     => 'chemnitz', 
      :location => 'alex-chemnitz'
    }
    assert_response :success
    assert_template 'frontend/location_images/_new'
    assert_select 'head', false
    assert_select 'body', false
  end
  
  def test_create
    LocationImage.delete_all
    ActionMailer::Base.deliveries = []
    assert_equal 0, LocationImage.count
    
    post :create, {
      :state    => 'sachsen',
      :city     => 'chemnitz', 
      :location => 'alex-chemnitz', 
      :location_image => {
        :image_file => File.open("#{Rails.root}/test/data/images/alex_chemnitz.jpg"),
        :general_terms_and_conditions => true
      },
      :frontend_user => {
        :email => 'alex-tester@example.com',
        :name  => 'alex tester'
      }
    }
    assert_response :success
    assert_template 'frontend/location_images/create'
    assert_select 'head' do
      assert_select 'title', 'Ein Bild zu ALEX Chemnitz (Sachsen) hochladen - www.example.com'
      assert_select 'meta[name=robots][content="noindex,follow"]', 1
    end
    assert_select 'body' do
      assert_select 'p', "We saved your image successfully.We sent you an email with an link to confirm your image. Without confirmation, we will remove the image after about #{LocationImage::UNPUBLISHED_VALID_FOR} hours.The example.com team will check all images. If an image does not agree with our terms and conditions, we will lock or remove it. You can now upload another image."
    end
    
    assert_equal 1, LocationImage.count
    assert_equal 1, ActionMailer::Base.deliveries.count
  end
  
  def test_confirm
    
  end
end