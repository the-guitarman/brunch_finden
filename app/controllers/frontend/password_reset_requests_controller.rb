#encoding: utf-8

class Frontend::PasswordResetRequestsController < Frontend::FrontendController
  #ssl_required :new, :create, :edit, :update
  #ssl_allowed :all
  
  #layout 'frontend/community'

  before_filter :require_no_user

  # Renders a form to let the user request for a password reset email.
  def new
    @login_or_email_blank = ''
    unless request.xhr?
      render({:template => 'frontend/password_reset_requests/new'})
    else
      render({:template => 'frontend/password_reset_requests/new.js.rjs'})
    end
  end

  # Sends an email to reset the user password, if the user exists, 
  # and renders the create template with a success message.
  def create
    if params[:login_or_email].blank?
      @login_or_email_blank = 'Bitte geben Sie Ihren Nutzernamen oder Ihre E-Mail-Adresse ein.'
      unless request.xhr?
        render({:template => 'frontend/password_reset_requests/new'})
      else
        render({:template => 'frontend/password_reset_requests/create.js.rjs'})
      end
      return true
    end
    
    @user = FrontendUser.find_by_username_or_email(params[:login_or_email])
    if @user
      # create a new token for the user
      @user.reset_perishable_token!
      # send the email
      if Rails.version >= '3.0.0'
        Mailers::Frontend::FrontendUserMailer.password_reset_instructions(@user).deliver
      else
        Mailers::Frontend::FrontendUserMailer.deliver_password_reset_instructions(@user)
      end
    end
    unless request.xhr?
      render({:template => 'frontend/password_reset_requests/create'})
    else
      render({:template => 'frontend/password_reset_requests/create.js.rjs'})
    end
  end

  # Renders the from to reset the user password.
  def edit
    if @user = FrontendUser.find_using_perishable_token(params[:id])
      render({:template => 'frontend/password_reset_requests/edit'})
    else
      render({:template => 'frontend/password_reset_requests/new'})
    end
  end

  # Saves the new user password or shows errors and renders a message.
  def update
    password_changed = false
    if @user = FrontendUser.find_using_perishable_token(params[:id])
      new_pw = params[:frontend_user][:password]
      new_pw_c = params[:frontend_user][:password_confirmation]
      if not new_pw.blank? and not new_pw_c.blank?
        @user.is_reseting_password = true
        #@user.save_without_session_maintenance
        password_changed = @user.update_attributes({
          :password => new_pw, :password_confirmation => new_pw_c
        })
        @user.is_reseting_password = false
      else
        @password_blank = 'Das Passwort und die Wiederholung sind leer.'
      end
    end
    if logged_in?
      current_user_session.destroy
    end
    @current_user = nil
    @current_user_session = nil
    if @user and password_changed
      @current_user_session = FrontendUserSession.new
      render({:template => 'frontend/password_reset_requests/update'})
    elsif @user and !password_changed
      render({:template => 'frontend/password_reset_requests/edit'})
    else
      render({:template => 'frontend/password_reset_requests/new'})
    end
  end
end
