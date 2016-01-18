class Backend::CitiesController < Backend::BackendController
  def show
    city = City.find(params[:id])
    render :json => city.to_ext_json(:format=>:plain)
  end
  
  def get_rewrite_suggestion
    ret = {:success => false}
    city = nil
    unless params[:id].blank?
      city = City.find_by_id(params[:id])
    end
    name = params[:name].to_s.strip
    unless name.blank?
      ret[:success] = true
      if city
        ret[:rewrite_suggestion] = City.generate_rewrite(name, city.id)
      else
        ret[:rewrite_suggestion] = City.generate_rewrite(name)
      end
    end
    render :json => ret.to_json
  end

  def create
    ext_params = decode_ext
    city = City.create(ext_params['city'])
    if city.errors.empty?
      render :json => city.to_ext_json(:format=>:plain)
    else
      render :json => city.to_ext_json(:format=>:simple_without_moduls)
    end
  end

  def update
    ext_params = decode_ext
    city = City.find(ext_params['city']['id'])
    city.update_attributes(ext_params['city'])
    if city.errors.empty?
      render :json => city.to_ext_json(:format=>:plain)
    else
      render :json => city.to_ext_json(:format=>:simple_without_moduls)
    end
  end
end
