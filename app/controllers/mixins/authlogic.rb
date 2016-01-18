module Mixins::Authlogic
  def self.included(klass)
    klass.instance_eval do
      #extend ClassMethods
      include InstanceMethods
      
      helper_method :logged_in?, :current_user_session, :current_user
    end
  end
  
  module InstanceMethods
    def current_user
  #    @current_user ||= current_user_session and current_user_session.frontend_user
      @current_user = nil
      if current_user_session and current_user_session.frontend_user
        @current_user  = current_user_session.frontend_user
      end
      return @current_user
    end

    def current_user_session
      return @current_user_session ||= FrontendUserSession.find
    end

    def logged_in?
      not current_user.nil?
    end

    def require_user
      unless logged_in?
        store_location
        if current_user_session and current_user_session.stale?
          flash[:notice] = t('shared.login_timeout')
        else
          flash[:notice] = t('shared.login_required')
        end
        redirect_to frontend_user_login_url
        return false
      else
        current_user
      end
    end

    def require_no_user
      if logged_in?
        store_location
        flash[:notice] = t('shared.logout_required')
        redirect_to frontend_user_account_url
        return false
      end
    end
    
    def store_location
      session[:frontend_return_to] = request.fullpath
    end
    
    def store_last_location
      session[:frontend_return_to] = request.env["HTTP_REFERER"]
    end
    
    def redirect_back_or_default(default)
      redirect_to(session[:frontend_return_to] || default)
      session[:frontend_return_to] = nil
    end
  end
  
  #module ClassMethods
  #  
  #end
end