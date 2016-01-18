module Mixins::HasUserRoles
  def self.included(klass)
    klass.instance_eval do
      include InstanceMethods
      extend ClassMethods
    end
  end

  module InstanceMethods
    #def possible_roles=(roles) @pos_roles=roles; end
    #def possible_roles; @pos_roles;end

    def roles=(roles)
      if roles.is_a?(String)
        roles = roles.split(%r{,\s*})
      elsif roles.is_a?(Symbol)
        roles = [roles.to_s]
      else
        roles.map{|r| r.to_s}
      end
      self.user_roles = (roles & self.class.possible_roles).join(",")
    end

    def roles
      user_roles = self.user_roles
      if user_roles.nil?
        user_roles = ''
      end
      user_roles.split(%r{,\s*})
    end

    def is?(role)
      roles.include?(role.to_s)
    end
  end

  module ClassMethods
    attr_reader :possible_roles
    def set_roles(r)
      @possible_roles = r.map{|r| r.to_s}
    end
  end
end
