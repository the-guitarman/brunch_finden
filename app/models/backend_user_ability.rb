class BackendUserAbility
  include CanCan::Ability
  
  # All backend tool group names. This represents the sort of the 
  # groups in the toolbox menu.
  BACKEND_TOOL_GROUPS = [:locations, :coupons, :statistics, :users]
  # BACKEND_TOOLS = { 
  #   :tool_group => [
  #     [:tool_name, :tool_permission, :backend_index_controller_action_name]
  #   ]
  # }
  BACKEND_TOOLS = {
    :locations => [
      [:location_manager, :access_location_manager, :location_manager],
    ],
    :coupons => [
    #  [:coupon_manager, :access_coupon_manager, :coupon_manager]
    ],
    :statistics => [
    #  [:clickouts, :access_clickouts, :clickouts]
    ],
    :users => [
      #[:frontend_user_manager, :access_frontend_user_manager, :frontend_user_manager],
      [:backend_user_manager, :access_backend_user_manager, :backend_user_manager]
    ]
    
    # ... to be continued
  }
  
  def initialize(user, request = nil)
    user = BackendUser.new if user.blank?
    
    if user.is?(:administrator)
      can :manage, :all
    end
    
    if user.is?(:management)
      can :access_frontend_user_manager, :all
      can :access_location_manager, :all
      can :access_coupon_manager, :all
      can :access_clickouts, :all
    end
    
    if user.is?(:staff)
      can :access_location_manager, :all
      can :access_coupon_manager, :all
    end
    
    if user.is?(:student)
      can :access_location_manager, :all
      can :access_coupon_manager, :all
    end
  end
end