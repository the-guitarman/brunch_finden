class String

  alias_method "include_string?", "include?"

  #String includes one of Arrays elements ?
  def include_one_of?(other)
    unless other.collect {|string| true if self.include_string? string}.compact.blank?
      return true
    else
      return false
    end
  end

  # extended include to match against Arrays, too
#  def include?(other)
#    if other.kind_of? String
#      return self.include_string? other
#    else
#      include_one_of?(other)
#    end
#  end

  # test, wether string is a number or not
  # "512".is_numeric?     => true
  # "512.99".is_numeric?  => true
  # " 512 ".is_numeric?   => true
  # "512,99".is_numeric?  => false
  # "512 Mb".is_numeric?  => false
  # "EUR 10".is_numeric?  => false
  def is_numeric?(options={:decimals => true})
    begin
      if options[:decimals] == true
        Float(self)
      else
        Integer(self)
      end
      return true
    rescue
      return false
    end
  end

  def to_hex
    email_address_encoded = ''
    self.each_byte do |c|
      email_address_encoded << sprintf("&#%d;", c)
    end
    return email_address_encoded
  end

  def sanitize
    ret = self
    if Object.constants.include?('Sanitize')
      ret = Sanitize.clean(ret)
    elsif Object.constants.include?('HTML') and HTML.constants.include?('FullSanitizer')
      ret = HTML::FullSanitizer.new.sanitize(ret)
    else
      ret = CGI.escapeHTML(ret)
    end
    return ret
  end

  def sanitize!
    self.gsub!(self, sanitize)
  end
end
