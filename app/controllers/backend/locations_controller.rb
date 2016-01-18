class Backend::LocationsController < Backend::BackendController
  include LibForwarding
  
  def show
    location = Location.find(params[:id])
    render :json => location.to_ext_json(:format=>:plain)
  end
  
  def get_rewrite_suggestion
    ret = {:success => false}
    location = nil
    unless params[:id].blank?
      location = Location.find_by_id(params[:id])
    end
    name = params[:name].to_s.strip
    unless name.blank?
      ret[:success] = true
      if location
        ret[:rewrite_suggestion] = Location.generate_rewrite(name, location.id)
      else
        ret[:rewrite_suggestion] = Location.generate_rewrite(name)
      end
    end
    render :json => ret.to_json
  end

  def create
    ext_params = decode_ext
    location = Location.create(ext_params['location'])
    if location.errors.empty?
      render :json => location.to_ext_json(:format=>:plain)
    else
      render :json => location.to_ext_json(:format=>:simple_without_moduls)
    end
  end

  def update
    ext_params = decode_ext
    location = Location.find(ext_params['location']['id'])
    location.update_attributes(ext_params['location'])
    if location.published == false
      source_path = "/#{location.rewrite}.html"
      destination_path = "/#{location.zip_code.city.rewrite}"
      create_forwarding(source_path, destination_path)
    end
    if location.errors.empty?
      render :json => location.to_ext_json(:format=>:plain)
    else
      render :json => location.to_ext_json(:format=>:simple_without_moduls)
    end
  end
end
