# encrypted strings is used for kill bill within login_switch? method
require 'encrypted_strings'

class Frontend::UserSessionsController < Frontend::FrontendController
  #ssl_required :new, :create
  
  #layout 'frontend/community'

  before_filter :require_user,    :except => [:new, :create, :create_review_author, :create_image_uploader]
  before_filter :require_no_user, :only   => [:new, :create, :create_review_author, :create_image_uploader]

  def new
    @current_user_session = FrontendUserSession.new
  end

  def create
    if user_login
      # user session created, user has logged in successfully, 
      # so initialize @current_user now
      current_user

      # Check for the KillBill-Login-Switches-Criteria
      # It is just a silent counter and cookie-based.
      login_switch?

      unless request.xhr?
        redirect_back_or_default(frontend_user_account_url)
      else
        render({:template => 'frontend/user_sessions/create.js.rjs'})
      end
    else
      unless request.xhr?
        render({:template => 'frontend/user_sessions/new'})
      else
        render({:template => 'frontend/user_sessions/create.js.rjs'})
      end
    end
  end
  
  def create_review_author
    user_login
    render :template => 'frontend/user_sessions/create_review_author.js.rjs'
  end

  def create_image_uploader
    user_login
    render :template => 'frontend/user_sessions/create_image_uploader.js.rjs'
  end

  def destroy
    current_user_session.destroy
    @current_user = FrontendUser.new
    @current_user_session = FrontendUserSession.new
    unless request.xhr?
      flash[:info] = 'Sie haben sich erfolgreich abgemeldet.'
      render :template => 'frontend/user_sessions/new'
    else
      render({:template => 'frontend/user_sessions/destroy.js.rjs'})
    end
  end
  
  private
  
  def user_login
    @current_user_session = FrontendUserSession.new(params[:frontend_user_session])
    return @current_user_session.save
  end

  # KillBill counter for account cheaters. 
  # It does nothing unless the user switches accounts, 
  # just manages a verification-cookie. 
  def login_switch?
    secret_key = "kill_bill_#{@host_name}!"
    new_digest = current_user.id.to_s.encrypt(:symmetric, {:password => secret_key})
    if cookies[:layout_settings]
      # cookie name obfuscates intention ;)
      old_digest = cookies[:layout_settings].decrypt(:symmetric, {:password => secret_key}) 
      unless old_digest.nil? or current_user.id == old_digest.to_i
        AccountCheater.add_switch(current_user, request, old_digest.to_i)
      end
      #set a fresh digest cookie
      cookies.delete(:layout_settings)
    end
    cookies[:layout_settings] = {:value => new_digest, :expires => 30.days.from_now}
  end
end
