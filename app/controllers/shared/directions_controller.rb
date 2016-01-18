class Shared::DirectionsController < ApplicationController
  def show_location_directions
    my_positions = [:auto, :manual]
    travel_modes = [:WALKING, :BICYCLING, :TRANSIT, :DRIVING]
    @location = Location.find(params[:id])
    
    my_position = params[:my_position].to_s.upcase.to_sym
    @my_position = if my_positions.include?(my_position)
      my_position
    else
      my_positions.first
    end
    
    mode_of_travel = params[:mode_of_travel].to_s.upcase.to_sym
    @mode_of_travel = if travel_modes.include?(mode_of_travel)
      mode_of_travel
    else
      travel_modes.first
    end
    
    render({
      :partial => 'shared/directions/location_directions',
      :layout => false
    })
  end
  
  def show_location_at_map
    @location = Location.find(params[:id])
    render({
      :partial => 'shared/directions/location_map',
      :layout => false
    })
  end
end