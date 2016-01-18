#encoding: utf-8
require 'test_helper'
#require 'yaml'
#require 'yaml/encoding'
$KCODE = 'UTF8' unless RUBY_VERSION >= '1.9'
#require 'ya2yaml'



class LocalesTest < ActiveSupport::TestCase
  def setup
    @path = "#{Rails.root}/config/locales"
    @dont_check = ['date','time','datetime','number','support','i18n']
  end

  def test_01_locales_exist
    current_locales = [
      'de', # 'de-AT', 'de-CH',
      'en'
    ]

    # check current locales defined above, that they exist as files
    current_locales.each do |locale|
      files = Dir.glob("#{@path}/#{locale}.{rb,yml}")
      assert !files.empty?
    end

    # check, wether there are more locale files than
    # current locales defined in the array above
    all_files = Dir.glob("#{@path}/*.{rb,yml}")
    assert current_locales.length == all_files.length
  end

  def test_02_compare_locales_and_merge
    # find parent locales (there is no '-' in their)
    parent_locales = []
    all_files = Dir.glob("#{@path}/*.{rb,yml}")
    all_files.each do |file|
      basename = File.basename(file, File.extname(file))
      parent_locales << basename unless basename.include?('-')
    end

    # merge parents into its children
    # merge :de into :de-At and :de-CH and :fr into :fr-CH and ...
#    print "\n"
    parent_locales.each do |parent_locale|
      parent_file = Dir.glob("#{@path}/#{parent_locale}.{rb,yml}").first
      parent_data = load_file(parent_file).stringify_keys

      children_files = Dir.glob("#{@path}/#{parent_locale}-*.{rb,yml}")
#      puts "merge: #{parent_locale} => #{children_files.map{|f| File.basename(f, File.extname(f))}}"
      assert compare_locales(parent_data[parent_locale], parent_file, children_files)
    end

    # merge :en into all others
    en_file = Dir.glob("#{@path}/en.{rb,yml}").first
    en_data = load_file(en_file).stringify_keys
    all_files.delete_if{|f| f == en_file}
    locale = File.basename(en_file, File.extname(en_file))
#    puts "merge: en => #{all_files.map{|f| File.basename(f, File.extname(f))}}"
    assert compare_locales(en_data[locale], en_file, all_files)
  end

  private

  def load_file(file_name)
    ext = File.extname(file_name)
    if ext == '.rb'
      #eval(File.read(file_name))
      eval(IO.read(file_name), binding, file_name)
    elsif ext == '.yml'
      #YAML.load(File.open(file_name, 'r'))
      YAML::load(IO.read(file_name))
    else
      nil
    end
  end

  def save_file(file_name, data)
    ret = false
    ext = File.extname(file_name)
    if ext == '.rb'
#          text = "{\n  :'#{locale}' => {\n  "
#
#          data[locale].keys.each do |key|
#            text << data[locale][key].export_to_s + "\n\n"
#          end
#
#          text << "  }\n}\n"
#
#          puts text
    elsif ext == '.yml'
      File.open(file_name, "w") do |f|
        f.puts(data.ya2yaml({:indent_size => 2}))
      end
      ret = true
    end
    return ret
  end

  def compare_locales(test_data, test_file, other_files)
    ret = true
    other_files.delete_if{|file_name| file_name == test_file}
    other_files.each do |file_name|
      data = load_file(file_name).stringify_keys
      ext = File.extname(file_name)
      locale = File.basename(file_name, ext)
      
      if ext. == '.rb'
        test_data = test_data.deep_symbolize_keys
        data[locale] = data[locale].deep_symbolize_keys
      elsif ext. == '.yml'
        test_data = test_data.deep_stringify_keys
        data[locale] = data[locale].deep_stringify_keys
      end

      diff = compare_hashes(test_data, data[locale], '')

      unless diff.blank?
        ret = false
        new_locale_data = {}
        if ext. == '.rb'
          diff = diff.deep_symbolize_keys
          new_locale_data[locale.to_sym] = data[locale].deep_merge(diff)
        elsif ext. == '.yml'
          diff = diff.deep_stringify_keys
          new_locale_data[locale] = data[locale].deep_merge(diff)
        end
        
        unless ret = save_file(file_name, new_locale_data)
          puts file_name
          if ext. == '.rb'
            puts diff.export_to_s
          elsif ext. == '.yml'
            puts diff.ya2yaml({:indent_size => 2})
          end
        end
      end
    end
    return ret
  end

  def compare_hashes(h1, h2, space)
    ret = ''
    ret2 = {}
#    h1.stringify_keys!
#    h2.stringify_keys!

    # clean up h2
    h2_keys_unknown_in_h1 = h2.keys - h1.keys
    if h2_keys_unknown_in_h1.length > 0
      h2.delete_if{|key, value| h2_keys_unknown_in_h1.include?(key)}
    end

    # check h1 keys in h2
    h1.keys.each do |key|
      if h1[key].is_a?(Hash)
        if h2[key] and h2[key].is_a?(Hash)
          if (space.length == 0 and @dont_check.include?(key.to_s.downcase) == false) or space.length > 0
            temp = compare_hashes(h1[key], h2[key], space + '  ')
            unless temp.blank? #.gsub("\n", '').blank?
              ret += "#{space}#{key}\n#{temp}"
              ret2[key] = temp
            end
          end
        else
          ret += "#{space}#{key} - Should be a hash with these keys: #{h1[key].keys.join(', ')}.\n"
          ret2[key] = h1[key].dup
        end
      elsif [Array,Hash].include?(h2[key].class) == false and
            h1[key].class != h2[key].class
        ret += "#{space}#{key} - Should be an object of #{h1[key].class.name}.\n"
        ret2[key] = h1[key].dup
      end
    end
    
    #return ret
    return ret2
  end
end
