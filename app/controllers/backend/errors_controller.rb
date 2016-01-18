class Backend::ErrorsController < Backend::BackendController
  def show_log_tail
    log_file = "#{Rails.root}/log/#{Rails.env}.log"
    if log_file_exists = File.exist?(log_file)
      text = `tail -n 100 #{log_file}`
    else
      text = "Log file does not exist."
    end
    render :json => {
      :success => log_file_exists,
      :data => {:text => text || ''}
    }.to_ext_json(:format  => :plain)
  end
end
