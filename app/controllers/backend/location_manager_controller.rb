class Backend::LocationManagerController < Backend::BackendController
  include RewriteRoutes
  
  def search
    ret = {}
    query = params[:query].to_s.strip
    unless query.blank?
      locations = Location.search(query)
      locations.each do |location|
        ret = _get_new_locations_at(ret, location)
      end
    end
    render :json => {:success => true, :data => ret}.to_json
  end
  
  def get_root
    root = [{
        :item_id => 0,
        :text => 'Home',
        :leaf => false, 
        :class_name => 'Root',
        :new_locations_at => get_new_locations_at
    }]
    render :json => root.to_json
  end
  
  def get_items
    class_name = params[:class_name].to_s.strip
    if not class_name.blank? and class_name == 'ZipCode'
      zip_codes = ZipCode.find(params[:id])
      items = zip_codes.locations.find(:all, :order => 'name ASC')
      items = extend_location_items(items)
    elsif not class_name.blank? and class_name == 'City'
      city = City.find(params[:id])
      items = city.zip_codes.find(:all, :order => 'code ASC')
      items = extend_zip_code_items(items)
    elsif not class_name.blank? and class_name == 'CityChar'
      city_char = CityChar.find(params[:id])
      items = city_char.cities.find(:all, :order => 'name ASC')
      items = extend_city_items(items)
    elsif not class_name.blank? and class_name == 'State'
      state = State.find(params[:id])
      items = state.city_chars.find(:all, :order => 'start_char ASC')
      items = extend_city_char_items(items)
    else
      items = State.all
      items = extend_state_items(items)
    end
    render :json => items.to_json
  end
  
  def get_node
    class_name = params[:class_name]
    model_klass = class_name.constantize
    object = model_klass.find(params[:id])
    if not class_name.blank? and class_name == 'ZipCode'
      object = extend_zip_code_items([object])
    elsif not class_name.blank? and class_name == 'City'
      object = extend_city_items([object])
    elsif not class_name.blank? and class_name == 'CityChar'
      object = extend_city_char_items([object])
    elsif not class_name.blank? and class_name == 'State'
      object = extend_state_items([object])
    elsif not class_name.blank? and class_name == 'Location'
      object = extend_location_items([object])
    else
      raise 'Object class unknown.'
    end
    render :json => object.first.to_ext_json(:format => :plain)
  end

  def delete_node
    class_name = params[:class_name]
    model_klass = class_name.constantize
    object = model_klass.find(params[:id])
    if not class_name.blank? and class_name == 'ZipCode'
      object = extend_zip_code_items([object])
    elsif not class_name.blank? and class_name == 'City'
      object = extend_city_items([object])
    elsif not class_name.blank? and class_name == 'CityChar'
      object = extend_city_char_items([object])
    elsif not class_name.blank? and class_name == 'State'
      object = extend_state_items([object])
    elsif not class_name.blank? and class_name == 'Location'
      object = extend_location_items([object])
    else
      raise "Object class unknown (#{class_name})."
    end
    bulk_deletion(model_klass)
  end
  
  private
  
  def get_new_locations_at
    ret = {}
    locations = Location.find(:all, :conditions => {:published => false})
    locations.each do |location|
      ret = _get_new_locations_at(ret, location)
    end
    ret = nil if ret.empty?
    return ret
  end
  
  def _get_new_locations_at(ret, location)
    ret = insert_item(ret, location)
    ret = insert_item(ret, location.zip_code)
    ret = insert_item(ret, location.zip_code.city)
    ret = insert_item(ret, location.zip_code.city.city_char)
    ret = insert_item(ret, location.zip_code.city.state)
    return ret
  end
  
  def insert_item(hash, item)
    klass = item.class.name
    if hash.key?(klass)
      hash[klass] << item.id
    else
      hash[klass] = [item.id]
    end
    hash[klass].compact!
    hash[klass].uniq!
    return hash
  end
  
  def extend_state_items(items)
    ret = []
    items.each do |item|
      temp = item.attributes.except(:id)
      temp['item_id'] = item.id
      temp['text'] = "#{item.name} #{statistic(item.number_of_locations)}"
      temp['leaf'] = false
      temp['cls']  = 'folder'
      temp['class_name'] = item.class.name
      temp['item_url'] = state_rewrite_url(create_rewrite_hash(item.rewrite))
      ret << temp
    end
    return ret
  end
  
  def extend_city_char_items(items)
    ret = []
    items.each do |item|
      temp = item.attributes.except(:id)
      temp['item_id'] = item.id
      temp['text'] = "#{item.start_char.upcase} #{statistic(item.number_of_locations)}"
      temp['leaf'] = false
      temp['cls']  = 'folder'
      temp['class_name'] = item.class.name
      ret << temp
    end
    return ret
  end
  
  def extend_city_items(items)
    ret = []
    items.each do |item|
      temp = item.attributes.except(:id)
      temp['item_id'] = item.id
      temp['text'] = "#{item.name} #{statistic(item.number_of_locations)}"
      temp['leaf'] = false
      temp['cls']  = 'folder'
      temp['iconCls'] = 'tree-node-city'
      temp['class_name'] = item.class.name
      temp['item_url'] = city_rewrite_url(create_rewrite_hash(item.rewrite))
      ret << temp
    end
    return ret
  end
  
  def extend_zip_code_items(items)
    ret = []
    items.each do |item|
      temp = item.attributes.except(:id)
      temp['item_id'] = item.id
      temp['text'] = "#{item.code} #{statistic(item.number_of_locations)}"
      temp['leaf'] = false
#      temp['cls']  = 'file'
      temp['iconCls'] = 'tree-node-zip-code'
      temp['class_name'] = item.class.name
      ret << temp
    end
    return ret
  end
  
  def extend_location_items(items)
    ret = []
    items.each do |item|
      temp = item.attributes.except(:id)
      temp['item_id'] = item.id
      temp['text'] = item.name
      temp['leaf'] = true
#      temp['cls']  = 'file'
      temp['class_name'] = item.class.name
      temp['cls'] = "tree-node-location-published-#{item.published}"
      temp['iconCls'] = 'tree-node-location-leaf'
      temp['item_url'] = location_rewrite_url(create_rewrite_hash(item.rewrite))
      ret << temp
    end
    return ret
  end
  
  def statistic(text)
    ret =  '<span class="statistics">('
    ret += '<span class="number-of-locations">'
    ret += text.to_s
    ret += '</span>'
    ret += ')</span>'
    return ret
  end
end
