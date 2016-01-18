class Backend::BackendUsersController < Backend::BackendController
  before_filter :decode_ext_parmeters, :only => [:create, :update]
  
  def show
    backend_user = BackendUser.find(params[:id])
    render :json => backend_user.to_ext_json({:format => :simple})
  end
  
  def list
    backend_users = BackendUser.find(:all)
    render :json => backend_users.to_ext_json({
      :count  => backend_users.count, 
      :format => :simple
    })
  end
  
  def list_active_now
    range = params[:range] || 5
    #backend_users = BackendUser.where(['last_request_at >= ?', DateTime.now.ago(range.minutes)])
    backend_users = BackendUser.paginate({
      :conditions => ['last_request_at >= ?', Time.now.ago(range.minutes).utc]
    } + paging)
    render :json => backend_users.to_ext_json({
      :count  => backend_users.count, 
      :format => :simple
    })
  end
  
  def create
    authorize! :assign_roles, current_user  if @ext_params['backend_user']['user_roles']
    backend_user = BackendUser.create(@ext_params['backend_user'])
    render :text => backend_user.to_ext_json({:format => :simple})
  end
  
  def update
    backend_user = BackendUser.find(@ext_params['backend_user']['id'])
    authorize! :assign_roles, current_user  if @ext_params['backend_user']['user_roles']
    backend_user.update_attributes(@ext_params['backend_user'])
    render :text => backend_user.to_ext_json({:format => :simple})
  end
  
  def login
    success = true
    messages = []
    backend_user = BackendUser.find_by_id(params[:id])

    if @current_frontend_user_account_session ||= BackendUserSession.find
      # logout from frontend user account first, you are logged in
      @current_frontend_user_account_session.destroy
    end
    # login to the frontend user account
    @current_frontend_user_account_session = BackendUserSession.create(backend_user, false)
    unless @current_frontend_user_account_session.errors.empty?
      success = false
      @current_frontend_user_account_session.errors.each do |k,v|
        messages << "#{k}: #{v}"
      end
    end
    render :json => {:success => success, :messages => messages}.to_json
  end
  
  private
  
  def decode_ext_parmeters
    @ext_params = decode_ext
  end
end
