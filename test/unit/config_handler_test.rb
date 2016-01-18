#encoding: utf-8
require 'test_helper'

class ConfigHandlerTest < ActiveSupport::TestCase
  def setup
    @path = "#{Rails.root}/tmp"
    @base_name = :test_config
    @file = "#{@path}/#{@base_name}.yml"
    File.delete(@file) if File.exist?(@file)
  end
  
  def teardown
    delete_config_file
  end
  
  def test_read_file_which_exists
    read_file_which_exists
  end
  
  def test_write_file_which_exists
    read_file_which_exists
    
    config = read_config
    
    config[:new_key] = 'This is a new config.'
    ConfigHandlerTestClass.instance.write_test_config(config)
    
    config = read_config(true)
    assert_equal 'This is a new config.', config[:new_key]
  end
  
  def test_read_file_which_does_not_exist
    delete_config_file
    config = read_config
    assert config.nil?
  end
  
  def test_write_file_which_does_not_exist
    delete_config_file
    ConfigHandlerTestClass.instance.write_test_config({:new_key => 'This is a new config.'})
    
    config = read_config(true)
    assert_equal 'This is a new config.', config[:new_key]
  end
  
  def test_file_path
    prepare_config_handler_test_class
    assert_equal @file, ConfigHandlerTestClass.instance.test_config_file
  end
  
  private
  
  def delete_config_file
    File.delete(@file) if File.exist?(@file)
  end
  
  def read_config(reload = false)
    prepare_config_handler_test_class
    ConfigHandlerTestClass.instance.test_config(reload)
  end
  
  def prepare_config_handler_test_class
    eval("class ConfigHandlerTestClass
            include ConfigHandler
            acts_as_config_handler('#{@path}/', {:#{@base_name} => :yml}, {})
          end")
  end
  
  def read_file_which_exists
    start_time = Time.now
    File.open(@file, 'w') do |f|
      f.write({:now => start_time, :array => [1,2,3,4]}.to_yaml)
    end
    config = read_config
    
    assert config.is_a?(Hash)
    assert_equal start_time.to_s(:db), config[:now].to_s(:db)
    assert_equal [1,2,3,4], config[:array]
  end
end

