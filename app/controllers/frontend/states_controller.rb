class Frontend::StatesController < Frontend::FrontendController
  before_filter :find_state, :only => :show
  caches_action :show, :cache_path => :cache_state_with_start_char_path.to_proc
  #cache_sweeper :state_sweeper, :only => [:update, :create, :destroy]
  
  def show    
    @city_chars = @state.city_chars.find(:all, :order => 'start_char ASC')
    
    unless params[city_char_parameter]
      redirect_to(
        state_rewrite_url(
          create_rewrite_hash(@state.rewrite).merge({
            city_char_parameter => @city_chars.first.start_char.upcase
          })
        ), :status => :moved_permanently
      )
      return
    end
    
    unless @city_char = @city_chars.find{|cc| cc.start_char.upcase == params[city_char_parameter].to_s.upcase}
      raise ActiveRecord::RecordNotFound
    end
    
    @facebook_tags['og:type'] = 'state_province'
    @facebook_tags['og:url'] = state_rewrite_url(create_rewrite_hash(@state.rewrite))
    @facebook_tags['og:locality'] = @state.name
    @facebook_tags['og:region'] = @state.name
    
    @twitter_tags['twitter:url'] = state_rewrite_url(create_rewrite_hash(@state.rewrite))
    
    @page_header_tags_configurator.set_state(@state)
  end
  
  private
  
  def find_state
    unless params[:state].blank?
      unless @state = State.find_by_rewrite(params[:state])
        raise(ActiveRecord::RecordNotFound)
      end
    else
      @state = State.find(params[:id])
    end
  end
  
  def cache_state_with_start_char_path
    return state_rewrite_cache_key_with_start_char(@state.rewrite, params)
  end
end
