class Mobile::IndexController < Mobile::MobileController
  caches_page :index, :general_terms_and_conditions, :privacy_notice,
    :registration_information

  def index
    unless fragment_exist?(mobile_index_ct_states)
      @states = State.find(:all, {:order => 'name ASC'})
    end
  end

  def general_terms_and_conditions
    @info_email = info_email
  end

  def privacy_notice
    @info_email = info_email
  end

  def registration_information

  end

  private

  def info_email
    fec = CustomConfigHandler.instance.frontend_config
    return "info(at)#{fec['DOMAIN']['NAME']}".to_hex
  end
end
