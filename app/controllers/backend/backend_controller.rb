class Backend::BackendController < ApplicationController
  include Backend::IndexHelper
  include Shared::LocationImagesHelper
  
  #ssl_required :all
  
  before_filter :load_globals
  before_filter :current_user
  before_filter :require_user
  
  skip_before_filter :set_page_header_tag_configurator, :set_page_header_tags
  
  rescue_from CanCan::AccessDenied, :with => :access_denied_message

  helper_method :logged_in?, :current_user_session, :current_user
  
  def get_authenticity_token
    if protect_against_forgery?
      render :text => form_authenticity_token
    else
      render :text => ''
    end
  end

  def logout
    redirect_to :controller=>"shared/account", :action=>:logout, :from=>'backend'
  end

  protected
  
  def access_denied_message(exception)
    msg = exception.message
    msg += "<br />Access denied for: #{exception.action}"
    render :text => msg, :status => :forbidden, :layout => false
  end

  def render_invalid_authenticity_token(exception)
    log_error(exception)
    session[:backend_return_to] = nil
    @current_user_session = nil
    redirect_to :controller => 'backend/index'
  end

#  def render_error(exception)
    ## Render detailed diagnostics for unhandled exceptions rescued from
    ## a controller action.
    #rescue_action_locally(exception)
    ##rescue_with_handler(exception)
  #end

  def render_not_found(exception)
    # Render detailed diagnostics for unhandled exceptions rescued from
    # a controller action.
    rescue_action_locally(exception)
  end

  #------------------ current user ---------------------------------------------
  def current_user
    @current_user ||= current_user_session and current_user_session.backend_user
  end

  def current_user_session
    @current_user_session ||= BackendUserSession.find
  end
  
  def current_ability
    @current_ability ||= BackendUserAbility.new(current_user, request)
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
      if request.xhr?
        render(:json => {:success => false, :requested_url => request.url}, :status => 401)
      else
        redirect_to(:controller => 'backend/index', :action => :login)
      end
      return false
    end
  end


#  def require_no_user
#    if logged_in?
#      store_location
#      flash[:notice] = t('shared.logout_required')
#      redirect_to frontend_account_url
#      return false
#    end
#  end

  
  private

  def store_location
    session[:backend_return_to] = request.fullpath
  end

  def redirect_back_or_default(default)
    redirect_to(session[:backend_return_to] || default)
    session[:backend_return_to] = nil
  end

  def load_globals
    super
    @backend_config = CustomConfigHandler.instance.backend_config
    
    @domain_name = @frontend_config['BACKEND']['DOMAIN']
    @full_domain_name = @frontend_config['DOMAIN']['FULL_NAME']
    @backend = @frontend_config['BACKEND']['DOMAIN'] + @frontend_config['BACKEND']['PATH']
  end

  def paging(page=nil, per_page=nil)
    start = (params[:start] || 0).to_i
    per_page = per_page.is_a?(Integer) ? per_page : (params[:limit] || 50).to_i
    page = page.is_a?(Integer) ? page : (start/per_page)+1
    {:page=>page,:per_page=>per_page}
  end

  # depreciated by rails3 Relations
  # Please use paginated(Relation) instead of this.
  def paging_find(start=nil, limit=nil)
    start = start.is_a?(Integer) ? start : (params[:start] || 0).to_i
    limit = limit.is_a?(Integer) ? limit : (params[:limit] || 100).to_i
    {:offset=>start,:limit=>limit}
  end

  # Takes an Relation and operate with offset and limit on it, 
  # to get a page of results from start to limit.
  # options:
  # * start: offset to start
  # * limit: count elements on page
  # * default_limit: if no limit is given and params[:limit] is not set use
  # this
  def paginated(relation,options= {})
    start=options[:start]
    limit=options[:limit]
    default_limit=options[:default_limit]||100
    start = start.is_a?(Integer) ? start : (params[:start] || 0).to_i
    limit = limit.is_a?(Integer) ? limit : (params[:limit] || default_limit).to_i
    relation.offset(start).limit(limit)
  end

  def search_result_ceil(search_result_cnt)
    search_result_cnt>1000 ? 1000 : search_result_cnt
  end

  protected
  def ssl_allowed?
    true
  end
  
end  
