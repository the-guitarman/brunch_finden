module Frontend::GmapsHelper
  def geo_map(locations, init = {})
    # extract first location, to set the center of the map
    first_location = locations[0] #.delete_at(0)
    if first_location.key?(:title)
      first_location_title = first_location[:title].parameterize
    else
      first_location_title = request.host
    end
    
    #js = geo_map_js(first_location, locations, init)
    js = "geoMap(#{locations.to_json}, #{init.to_json});"
    
    content_for(:jquery_global, 'var map = null;'.html_safe)
    content_for(:jquery_on_ready, js.html_safe)
    return content_tag(:div, nil, {:id => :map, :class => "map-#{first_location_title}"}).html_safe
  end
  
  def geo_map_js(first_location, locations, init = {})
    js = "
      map = new GMaps({
        div:'#map',
        #{map_init(first_location, init)}
      });
      #{add_markers(locations)}
      //#{add_control}
    "
    return js.html_safe
  end
  
  private
  
  def map_init(location, init = {})
    #return "#{get_marker_position(location)},zoom:#{init[:zoom] || 6}"
    ret = "#{get_marker_position(location)}," + 
      "zoom:#{init[:zoom] || 6}," +
      "scaleControl:#{init[:scale_control].nil? ? true : init[:scale_control]}," +
      "rotateControl:#{init[:rotate_control].nil? ? true : init[:rotate_control]}," +
      "panControl:#{init[:pan_control].nil? ? true : init[:pan_control]}," +
      "navigationControl:#{init[:navigation_control].nil? ? true : init[:navigation_control]}," +
      "mapTypeId:google.maps.MapTypeId.ROADMAP," + #HYBRID, ROADMAP, SATELLITE, TERRAIN
      "mapTypeControl:#{init[:map_type_control].nil? ? true : init[:map_type_control]}," +
      "overviewMapControl:#{init[:overview_map_control].nil? ? true : init[:overview_map_control]}," +
      "streetViewControl:#{init[:street_view_control].nil? ? true : init[:street_view_control]}," +
      "zoomControl:#{init[:zoom_control].nil? ? true : init[:zoom_control]}"
    return ret
  end
  
  def add_markers(locations)
    return locations.map{|l| add_marker(l)}.join
  end
  
  def add_marker(location)
    ret = get_marker_position(location) + ',' +
          get_marker_title(location) + ',' +
          get_marker_icon(location)# + ',' +
          #get_marker_info_window(location)
    return "map.addMarker({#{ret}});\n"
  end
  
  def get_marker_position(location)
    return "lat:#{location[:lat]},lng:#{location[:lng]}"
  end
  
  def get_marker_title(location)
    return "title:\"#{location[:title].strip.gsub('"',"'").gsub("\n","")}\""
  end
  
  def get_marker_icon(location)
    return "icon:{url:'#{location[:icon][:url]}',scaledSize:#{location[:icon][:scaled_size]}}"
  end
  
  def get_marker_info_window(location)
    return "infoWindow:{content:\"#{location[:info_window][:content].gsub("\"", "'").gsub("\n","")}\"}"
  end
  
  def add_control
    # Note: You can use the following positions:
    # - top_center
    # - top_left
    # - top_right
    # - left_top
    # - right_top
    # - left_center
    # - right_center
    # - left_bottom
    # - right_bottom
    # - bottom_center
    # - bottom_left
    # - bottom_right
    
    # Controls
    # {
    #   panControl: boolean,
    #   zoomControl: boolean,
    #   mapTypeControl: boolean,
    #   scaleControl: boolean,
    #   streetViewControl: boolean,
    #   overviewMapControl: boolean
    # }
    
    #  ,
    #  events: {
    #    click: function(){
    #      console.log(this);
    #    }
    #  }

    ret = "
    map.addControl({
      position: 'top_right',
      content: 'Geolocate',
      style: {
        margin: '5px',
        padding: '1px 6px',
        border: 'solid 1px #717B87',
        background: '#fff'
      }
    });"
    return ret
  end
end
