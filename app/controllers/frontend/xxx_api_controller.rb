#class Frontend::ApiController < Frontend::FrontendController
#  def locations
#    if params[:city] == 'Chemnitz'
#      conditions = {}
#    elsif params[:city] == 'Leipzig'
#      conditions = {}
#    else
#      raise "Wrong city given (params[:city]: #{params[:city].inspect})."
#    end
#    locations = Location.to_csv(conditions)
#    respond_to do |format|
#      format.csv { render({:text => locations}) }
#    end
#  end
#end
