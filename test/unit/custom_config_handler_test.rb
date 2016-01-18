#encoding: utf-8
require 'test_helper'
require 'unit/helper/config_handler_test_helper'

class CustomConfigHandlerTest < ActiveSupport::TestCase
  include ConfigHandlerTestHelper
  
  CHECK_YML_FILES = {
    :stages => [:development, :production, :production_dev, :test]
  }
  
  def test_constants_included_modules_class_variables
    #assert CustomConfigHandler.constants.is_a?(Array)
    #assert CustomConfigHandler.constants.empty?
    
    modules = CustomConfigHandler.included_modules
    assert modules.include?(ConfigHandler)
    assert modules.include?(Singleton)
    
    assert CustomConfigHandler.class_variables.include?('@@config_files')
    assert CustomConfigHandler.config_files.is_a?(Hash)
    assert_equal :yml, CustomConfigHandler.config_files[:frontend_header_data_config]
    assert_equal :yml, CustomConfigHandler.config_files[:new_frontend_header_data_config]
    assert_equal :yml, CustomConfigHandler.config_files[:frontend_config]
    assert_equal :yml, CustomConfigHandler.config_files[:backend_config]
    assert_equal :yml, CustomConfigHandler.config_files[:bad_words]
    
    assert CustomConfigHandler.class_variables.include?('@@global_config_files')
    assert CustomConfigHandler.global_config_files.is_a?(Hash)
    assert_equal :txt, CustomConfigHandler.global_config_files[:advertising_opportunities]
    assert_equal :yml, CustomConfigHandler.global_config_files[:blacklisted_email_domains]
    
    assert CustomConfigHandler.class_variables.include?('@@files_path')
    assert CustomConfigHandler.files_path.is_a?(String)
    assert_equal "#{Rails.root}/config/custom/#{Rails.env}/", CustomConfigHandler.files_path
  end

  def test_defined_config_files
    path = CustomConfigHandler.files_path
    
    config_files = CustomConfigHandler.config_files
    config_files.each do |config_file|
      test_file = "#{path}#{config_file}"
      if File.exist?(test_file)
        # test deep copy of method output
        basename = File.basename(config_file, File.extname(config_file))
        test_method_1 = eval("CustomConfigHandler.instance.#{basename}")
        test_method_2 = eval("CustomConfigHandler.instance.#{basename}")
        if not test_method_1.blank? and  not test_method_2.blank?
          assert test_method_1.object_id != test_method_2.object_id
        end
        # test for same file content within the other stage configs
        other_files = Dir.glob("#{Rails.root}/**/#{config_file}")
        assert compare_configs(test_method_1, test_file, other_files)
      end
    end
    
    global_config_files = CustomConfigHandler.global_config_files
    global_config_files.each do |global_config_files|
      test_file = "#{path.gsub(/#{Rails.env}\/$/, '')}#{global_config_files}"
      if File.exist?(test_file)
        # test deep copy of method output
        basename = File.basename(global_config_files, File.extname(global_config_files))
        test_method_1 = eval("CustomConfigHandler.instance.#{basename}")
        test_method_2 = eval("CustomConfigHandler.instance.#{basename}")
        assert test_method_1.object_id != test_method_2.object_id
      end
    end
  end
  
  def test_all_stages_yml_files_will_be_readable_and_loadable
    files_path = CustomConfigHandler.files_path
    
    global_path = files_path.gsub("/#{Rails.env}/", "/")
    yml_files = Dir.glob(global_path + "*.yml")
    
    custom_paths = files_path.gsub("/#{Rails.env}/", "/{#{CHECK_YML_FILES[:stages].join(',')}}/")
    if Rails.version >= '3.0.0'
      yml_file_basenames = CustomConfigHandler.config_files.select{|f,t| t == :yml}.keys
    else
      yml_file_basenames = CustomConfigHandler.config_files.select{|f,t| t == :yml}.map{|el| el.last}
    end
    yml_files += Dir.glob(custom_paths + "{#{yml_file_basenames.join(',')}}.yml")
    
    yml_files.each do |file|
      begin
        result = (
          YAML::load(File.open(file, 'r')).is_a?(Hash) or 
          YAML::load(File.open(file, 'r')).is_a?(Array)
        )
        assert result, "Could not load #{file}."
      rescue Exception => e
        assert false, "Could not load #{file}. Error: #{e.message}"
      end
    end
  end
end
