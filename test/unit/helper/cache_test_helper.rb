# encoding: utf-8
require 'fileutils'

module CacheTestHelper
  def create_page_cache(request_path)
    file_name = page_cache_file(request_path)
    dir = File.dirname(file_name)
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    File.open(file_name, 'w') do |f|
      f.write('Test file: This file should not exist after the test.')
    end
    page_cache_exists?(request_path)
  end
  
  def page_cache_exists?(request_path)
    assert File.exist?(page_cache_file(request_path))
  end
  
  def page_cache_not_exists?(request_path)
    assert !File.exist?(page_cache_file(request_path))
  end
  
  def page_cache_delete?(request_path)
    file_name = page_cache_file(request_path)
    dir = File.dirname(file_name)
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    assert !File.exist?(file_name)
  end

  def delete_page_cache(request_path)
    #FileUtils.rm_rf(page_cache_file(request_path))
    file_name = page_cache_file(request_path)
    File.delete(file_name) if File.exist?(file_name)
  end
  
  def action_cache_exist?(path)
    assert App.fragment_exist?(path)
  end
  
  def action_cache_does_not_exist?(path)
    assert !App.fragment_exist?(path)
  end
  
  def create_action_cache(path)
    App.write_fragment(path, 'Test fragment: This fragment should not exist after the test.')
    action_cache_exist?(path)
  end
  
  def delete_action_cache(path)
    App.expire_fragment(path)
    action_cache_does_not_exist?(path)
  end
  
  private

  def page_cache_file(request_path)
    ret = ActionController::Base.send(:page_cache_file, request_path)
    class_name = self.class.name
    if class_name.start_with?('Frontend::')
      unless ret.start_with?(Frontend::FrontendController.page_cache_directory)
        ret = Frontend::FrontendController.page_cache_directory + ret
      end
    elsif class_name.start_with?('Mobile::')
      unless ret.start_with?(Mobile::MobileController.page_cache_directory)
        ret = Mobile::MobileController.page_cache_directory + ret
      end
    elsif self.class.ancestors.include?(ActiveSupport::TestCase)
      unless ret.start_with?(Frontend::FrontendController.page_cache_directory)
        ret = Frontend::FrontendController.page_cache_directory + ret
      end
    end
    return ret
  end
end