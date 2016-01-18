class Hash
  def +(other)
    self.merge(other)
  end

  # Stringify Symbol values of a hash.
  # Stringifies Symbols in an Array as hash values, too.
  def stringify_values
    clean_options={}
    each do |key,value|
      if value.is_a? Symbol
        clean_options[key]=value.to_s
      elsif value.is_a? Array
        ary=value.collect {|v| if v.is_a? Symbol then v.to_s else v end}
        clean_options[key]=ary
      else
        clean_options[key]=value
      end
    end
    clean_options
  end

  def deep_stringify_keys
    inject({}) { |result, (key, value)|
      value = value.deep_stringify_keys if value.is_a?(Hash)
      result[(key.to_s rescue key) || key] = value
      result
    }
  end unless Hash.method_defined?(:deep_stringify_keys)

  # An assert method should return true or false. The original method raises an
  # error, if one of the keys in hash match *valid_keys will mismatch.
  alias_method :original_assert_valid_keys, :assert_valid_keys
  def assert_valid_keys(*valid_keys)
    original_assert_valid_keys(*valid_keys)
    return true
  rescue
    return false
  end

  # serialize hash to string
  def export_to_s(indent=0)
#    puts "#{indent} - #{self.keys.inspect}"
    str = "{\n"

    self.keys.sort{|k1,k2| k1.to_s <=> k2.to_s}.each_with_index do |k, i|
      str << ("  " * (indent+1))
      str << "#{k.inspect} => "
      if self[k].kind_of?(Hash)
        str << self[k].export_to_s(indent+1)
      else
        str << self[k].inspect
      end
      str << "," if i < (self.keys.size - 1)
      str << "\n"
    end

    str << ("  " * (indent))
    str << "}"

    str
  end unless Hash.method_defined?(:export_to_s)
  
  def extract(*keys)
    ret = {}
    keys.each do |key|
      ret[key] = self[key] if self.key?(key)
    end
    return ret
  end
  
  def copy
    Hash.copy(self)
  end
  
  def self.copy(value)
    if value.is_a?(Hash)
      result = {}
      value.each{|k, v| result[k] = copy(v)}
      result
    elsif value.is_a?(Array)
      result = []
      value.each{|v| result << copy(v)}
      result
    elsif value.is_a?(String)
      String.new(value)
    else
      value
    end
  end
  
  # Returns deeply nested values from hashes
  # h = {:company => {:phone_numbers => {:big_boss => 123, :supervisor => "456"}}}
  # => {:company => {:phone_numbers => {:big_boss => 123, :supervisor => "456"}}}
  # 
  # phone_number = h.seek :company, :phone_numbers, :big_boss
  # => 123
  # 
  # phone_number = h.seek :company, :phone_numbers, :big_boss, {:new_value => 789}
  # => 789
  # 
  # h
  # => {:company => {:phone_numbers => {:big_boss => 789, :supervisor => "456"}}}
  # 
  # phone_number = h.seek :company, :phone_numbers, :boss
  # => nil
  # 
  # phone_number = h.seek :company, :phone_numbers, :boss, {:default => false}
  # => false
  def seek(*keys)
    level = self
    value = nil
    options = keys.extract_options!
 
    keys.each_with_index do |key, idx|
      if level.is_a?(Hash) and level.key?(key)
        if idx + 1 == keys.length
          if options[:new_value].nil?
            value = level[key]
          else
            value = level[key] = options[:new_value] 
          end
        else                   
          level = level[key]
        end
      else 
        break
      end
    end
    
    if value.nil? and not options[:default].nil?
      value = options[:default]
    end
 
    return value
  end
end
