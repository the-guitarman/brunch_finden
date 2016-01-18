class Backend::StatesController < Backend::BackendController
  def show
    state = State.find(params[:id])
    render :json => state.to_ext_json(:format=>:plain)
  end
  
  def get_rewrite_suggestion
    ret = {:success => false}
    state = nil
    unless params[:id].blank?
      state = State.find_by_id(params[:id])
    end
    name = params[:name].to_s.strip
    unless name.blank?
      ret[:success] = true
      if state
        ret[:rewrite_suggestion] = State.generate_rewrite(name, state.id)
      else
        ret[:rewrite_suggestion] = State.generate_rewrite(name)
      end
    end
    render :json => ret.to_json
  end

  def create
    ext_params = decode_ext
    state = State.create(ext_params['state'])
    if state.errors.empty?
      render :json => state.to_ext_json(:format=>:plain)
    else
      render :json => state.to_ext_json(:format=>:simple_without_moduls)
    end
  end

  def update
    ext_params = decode_ext
    state = State.find(ext_params['state']['id'])
    state.update_attributes(ext_params['state'])
    if state.errors.empty?
      render :json => state.to_ext_json(:format=>:plain)
    else
      render :json => state.to_ext_json(:format=>:simple_without_moduls)
    end
  end
end
