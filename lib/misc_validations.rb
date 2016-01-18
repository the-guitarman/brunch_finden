class MiscValidations

  def self.validate_email(email)
    reg = Regexp.new(Authlogic::Regex.email)
    return (reg.match(email))? true : false
  end


end
