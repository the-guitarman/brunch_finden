class Backend::UserSessionsController < Backend::BackendController
  #ssl_required :new, :create

  #before_filter :require_no_user, :only => [:new, :create]
  #before_filter :require_user, :only => :destroy
  #skip_before_filter :set_page_header_tags, :only => [:create, :destroy]
  skip_before_filter :require_user, :only => [:new, :create]

  def new
    redirect_to :controller => 'backend/index', :action => :login
  end

  def create
    @user_session = BackendUserSession.new(params[:backend_user_session])
    if @user_session.save
      current_user
      #flash[:notice] = c_t('.login_successful')
      #redirect_back_or_default :controller => 'backend/index', :action => :backend_menu
      render :json => {:success => true}.to_json
    else
      errors = {}
      @user_session.errors.each do |key, value|
        errors.merge!({"backend_user_session[#{key}]" => value})
      end
      render :json => {:success => false, :errors => errors}.to_json
      #render :action => :new
      #render :template => 'backend/user_sessions/new', :layout=>'backend/login'
    end
  end

  def destroy
    current_user_session.destroy
#    flash[:notice] = c_t('.logout_successful')
    redirect_to :controller => 'backend/index', :action => :login
  end
end