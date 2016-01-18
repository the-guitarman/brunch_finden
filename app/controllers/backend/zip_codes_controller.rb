class Backend::ZipCodesController < Backend::BackendController
  def show
    zip_code = ZipCode.find(params[:id])
    render :json => zip_code.to_ext_json(:format=>:plain)
  end

  def create
    ext_params = decode_ext
    zip_code = ZipCode.create(ext_params['zip_code'])
    if zip_code.errors.empty?
      render :json => zip_code.to_ext_json(:format=>:plain)
    else
      render :json => zip_code.to_ext_json(:format=>:simple_without_moduls)
    end
  end

  def update
    ext_params = decode_ext
    zip_code = ZipCode.find(ext_params['zip_code']['id'])
    zip_code.update_attributes(ext_params['zip_code'])
    if zip_code.errors.empty?
      render :json => zip_code.to_ext_json(:format=>:plain)
    else
      render :json => zip_code.to_ext_json(:format=>:simple_without_moduls)
    end
  end
end
