# encoding: utf-8

module ConfigHandlerTestHelper

  private

  def compare_configs(test_config, test_config_file, other_configs)
    ret = true
    other_configs.delete_if{|file| file == test_config_file}
    other_configs.each do |file|
      bec = YAML.load(File.open(file, 'r'))
      if test_config.is_a?(Hash)
        result = compare_hashes(test_config, bec, '  ')
      elsif test_config.is_a?(Array)
        result = compare_arrays(test_config, bec)
      end
      unless result.blank?
        ret = false
        puts "file: #{file}"
        puts "result: #{result}"
      end
    end
    return ret
  end

  def compare_arrays(a1, a2)
    a2.each do |el|
      unless a1.include?(el)
        return "#{el} not found."
      end
    end
    return nil
  end

  def compare_hashes(h1, h2, space)
    ret = ''
    h1.stringify_keys!
    h2.stringify_keys!

    # find missing keys in h2
    known_keys = []
    h1.keys.each do |key, value|
      unless h2.has_key?(key)
        ret += "#{space} #{key} - Key does not exist.\n"
      else
        known_keys << key
      end
    end

    # check found keys in h2
    known_keys.each do |key|
      if h1[key].is_a?(Hash) 
        if h2[key] and h2[key].is_a?(Hash)
          temp = compare_hashes(h1[key], h2[key], space + '  ')
          ret += "#{space}#{key}\n#{temp}" unless temp.gsub("\n", '').blank?
        else
          ret += "#{space} #{key} - Should be a hash with these keys: #{h1[key].keys.join(', ')}.\n"
        end
      elsif h1[key].class != h2[key].class
        ret += "#{space} #{key} - Should be an object of #{h2[key].class.name}.\n"
      end
    end
    
    return ret
  end
end