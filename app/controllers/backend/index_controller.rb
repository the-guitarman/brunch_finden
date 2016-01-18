require 'money'

class Backend::IndexController < Backend::BackendController
  before_filter :accessable_backend_tools
  before_filter :check_permission,         :except => [:login, :index, :backend_menu]
  skip_before_filter :require_user, :only => :login

  def index
    render :text => '', :layout => 'backend/backend_menu'
  end

  def backend_menu
    render :template => 'backend/menu_main', :layout => false
  end
  
  # ----------------------------------------------------------------------------
  # Tools

  def backend_user_manager
    @backend_user_admin_role = BackendUser::ADMIN_ROLE
    @backend_user_roles = BackendUser::ROLES.sort{|x,y| x.to_s <=> y.to_s}
    @backend_user_user_groups = BackendUser::USER_GROUPS.sort
    @backend_user_salary_types = BackendUser::SALARY_TYPES.sort
    @backend_user_countries = BackendUser::COUNTRIES.map{|c| [c.to_s, I18n.t("shared.countries.#{c}")]}.sort
    @all_backend_tools = BackendUserAbility::BACKEND_TOOLS
    render :text => '', :layout => "backend/backend_user_manager"
  end
  
  def clickouts
    render :text => '', :layout=>'backend/clickouts'
  end
  
  def coupon_manager
    @coupon_types = Coupon::TYPES
    render :text => '', :layout=>'backend/coupon_manager'
  end
  
  def location_manager
    @new_image_state = LocationImage::NEW_IMAGE_STATE
    render :text => '', :layout=>'backend/location_manager'
  end

  def login
    @full_domain_name = @frontend_config['DOMAIN']['FULL_NAME']
    render :text => '', :layout=>'backend/login'
  end
  
  private
  
  def accessable_backend_tools
    @backend_tool_groups = BackendUserAbility::BACKEND_TOOL_GROUPS
    @accessible_backend_tools = {}
    @backend_tool_groups.each do |tool_group|
      tools = BackendUserAbility::BACKEND_TOOLS[tool_group]
      unless tools.empty?
        tools.each do |tool|
          tool_name, permission, action = tool
          if can?(permission.to_sym, :all)
            unless @accessible_backend_tools[tool_group]
              @accessible_backend_tools[tool_group] = []
            end
            @accessible_backend_tools[tool_group] << [tool_name, action]
          end
        end
      end
    end
  end
  
  def check_permission
    permission = nil
    BackendUserAbility::BACKEND_TOOLS.values.map{|tg| tg.map{|t| {t[2] => t[1]}}}.flatten.each do |el|
      break if permission = el[action_name.to_sym]
    end
    authorize! permission, current_user
  end
end
