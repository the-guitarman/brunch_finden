#encoding: utf-8
class Frontend::UsersController < Frontend::FrontendController
  #ssl_required :new, :create, :change_message_settings, :change_password, :change_bank_account
  
  #layout 'frontend/community'

  before_filter :require_user, :only => [:show, :confirm_later]
  before_filter :require_no_user, :only => [:new, :create] #, :confirm
  
  helper_method :confirmation_period

  def show
    @user = FrontendUser.find_by_login(params[:login])
  end

  def new
    @current_user = FrontendUser.new
  end

  def create
    @frontend_user_params = params[:frontend_user]
    @frontend_user_params
    @current_user = check_for_unknown_user(@frontend_user_params)
    if @current_user.unknown?
      @current_user.attributes = @frontend_user_params
      @current_user.set_init_state
    end
    if @current_user.save
      @current_user_session = FrontendUserSession.create(@current_user, false)
      unless request.xhr?
        redirect_to(frontend_user_account_url)
      else
        render({:template => 'frontend/users/create.js.rjs'})
      end
    else
      @current_user_session = FrontendUserSession.new
      unless request.xhr?
        render({:template => 'frontend/users/new'})
      else
        render({:template => 'frontend/users/create.js.rjs'})
      end
    end
  end

  # Confirms a user via link (delivered by an email).
  def confirm
    confirm_user(params[:confirmation_code])
    if @user and @user.confirmed?
      @current_user_session = FrontendUserSession.new
      render :template => 'frontend/users/confirmed'
    else
      render :template => 'frontend/users/confirm_now'
    end
  end

  # Confirms a user by a confirmation code manually.
  def confirm_now
    confirm_user(params[:confirmation_code])
    unless request.xhr?
      if @user and @user.confirmed?
        unless logged_in?
          @current_user_session = FrontendUserSession.new
          render({:template => 'frontend/users/confirmed'})
        else
          flash[:info] = c_t(:success_message, {:domain_name => @host_name})
          redirect_to(frontend_user_account_url)          
        end
      else
        render({:template => 'frontend/users/confirm_now'})
      end
    else
      render({:template => 'frontend/users/confirm_now.js.rjs'})
    end
  end
  
  def confirm_new_user_now
    @later_confirmation = true
    confirm_now
  end
  
  def confirm_later
    unless request.xhr?
      redirect_to(frontend_user_account_url)
    else
      render({:template => 'frontend/users/confirm_later.js.rjs'})
    end
  end
  
  def confirm_new_email
    confirm_user(params[:confirmation_code])
    if @user and @user.confirmed?
      render_new_email_confirmed
    else
      set_confirmation_code_error_message
      render :template => 'frontend/users/new_email_confirm_now'
    end
  end
  
  def confirm_new_email_now
    @confirmation_code_blank = ''
    confirm_user(params[:confirmation_code])
    if @user and @user.confirmed?
      render_new_email_confirmed
    else
      if params.key?(:confirmation_code)
        set_confirmation_code_error_message
      end
      render :template => 'frontend/users/new_email_confirm_now'
    end
  end
  
  private
  
  def check_for_unknown_user(parameters)
    frontend_user = FrontendUser.new(parameters)
    frontend_user.valid?
    if (not frontend_user.email.blank?) and frontend_user.errors[:email].any?
      if user = FrontendUser.find_by_email(frontend_user.email)
        if user.unknown?
          frontend_user = user
          frontend_user.attributes = parameters.except(:email, :login)
        end
      end
    end
    return frontend_user
  end

  def confirm_user(confirmation_code)
    @user = nil
    unless @user = FrontendUser.waiting.find_by_perishable_token(confirmation_code)
      @user = FrontendUser.changing_email.find_by_perishable_token(confirmation_code)
    end
    if @user
      unless @user.new_email.blank?
        @user.email = @user.new_email
      end
      @user.confirm!
    end
  end
  
  def confirmation_period
    @confirmation_period = FrontendUser.confirmation_period
  end
  
  def render_new_email_confirmed
    unless logged_in?
      @current_user_session = FrontendUserSession.new
      render({:template => 'frontend/users/new_email_confirmed'})
    else
      flash[:info] = c_t('.confirmed_message')
      redirect_to(frontend_user_edit_profile_url)
    end
  end
  
  def set_confirmation_code_error_message
    error = params[:confirmation_code].blank? ? 'blank' : 'error'
    @confirmation_code_blank = c_t(".confirmation_code_#{error}")
  end
end
