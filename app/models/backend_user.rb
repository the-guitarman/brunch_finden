class BackendUser < ActiveRecord::Base  
  ADMIN_ROLE = :administrator
  ROLES = [:management, :staff, :student]
  
  GENDERS = {
    :mr => 'male', 
    :ms => 'female'
  }
  COUNTRIES = [:germany, :thailand]
  
  USER_GROUPS  = {0 => :management, 1 => :staff, 2 => :student}
  SALARY_TYPES = {0 => :none,  1 => :minijob, 2 => :midijob, 3 => :invoice}
  
  include Mixins::HasUserRoles
  set_roles([ADMIN_ROLE]+ROLES)

  # VALIDATIONS ----------------------------------------------------------------
  validates_presence_of :first_name, :name, :gender, :country, :user_group, 
    :salary_type, :user_roles

  # AUTHLOGIC ------------------------------------------------------------------

  acts_as_authentic do |config|
    config.login_field = :login
    config.merge_validates_format_of_login_field_options({
      :with => /^[\w\d][\w\d\-@]+[\w\d]$/,
      :message => I18n.t('error_messages.login_invalid',
        :default => "should use only letters, numbers, and -@ please.")
    })
    config.logged_in_timeout = 1.hours #120.minutes # default is 10.minutes
  end
  
  # INSTANCE METHODS -----------------------------------------------------------

  def full_name(with_salutation=false)
    ret = ''
    ret += self.first_name + ' ' if self.first_name?
    ret += self.name if self.name?
    if with_salutation and self.salutation? and !ret.blank?
      ret = self.salutation + ' ' + ret
    end
    return ret
  end
  
  def user_roles
    user_roles_array(read_attribute(:user_roles).to_s.split(',')).join(',')
  end
  
  def user_roles=(roles)
    roles = user_roles_array(roles).join(',') if roles.is_a?(Array)
    write_attribute(:user_roles, roles)
  end
  
  def role_name
    user_roles
  end
  
  private 
  
  def user_roles_array(roles)
    roles = roles.to_s.split(',') if roles.is_a?(String)
    roles.map{|ur| ur.to_s.strip.to_s}.compact.uniq.sort
  end
end
