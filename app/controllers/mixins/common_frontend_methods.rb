module Mixins::CommonFrontendMethods
  def self.included(klass)
    klass.instance_eval do
      #extend ClassMethods
      include InstanceMethods
    end
  end
  
  module InstanceMethods
    def page(key = :page)
      page = params[key].to_i
      page = 1 if page < 1
      return page
    end
    
    private
    
    # Returns a frontend user (Class: {FrontendUser}). 
    # If the user is logged in, it's the current user. Otherwise it tries to 
    # find the frontend user by its email. If no user was found, it returns a 
    # new frontend user object with unknown state.
    def find_or_initialize_frontend_user
      ret = nil
      # frontend user ...
      if logged_in?
        # ... is logged in
        ret = current_user
      else
        # ... is not logged in
        attr = params[:frontend_user] || {}
        attributes = {}
        attributes[:email] = attr[:email] || attr['email']
        attributes[:name] = attr[:name] || attr['name']
        ret = FrontendUser.find_or_initialize_by_email(params[:frontend_user])
        if ret.new_record?
          ret.unknown
        elsif ret.unknown?
          ret.name = attributes[:name]
        end
      end
      return ret
    end

    # Logs the user in, if there are valid params (may be 
    # autocompleted by the browser)
    def autologin_the_user
      #unless logged_in?
      #  FrontendUserSession.create(params[:frontend_user_session])
      #end
    end

    # Returns true, if all given objects are valid. Otherwise false.
    def validate_objects(*objects)
      ret = true
      objects.each do |object|
        unless object.is_a?(Array)
          ret = false unless object.valid?
        else
          ret = false unless object.collect{|o| o.valid?}.all?
        end
      end
      return ret
    end
  end
end