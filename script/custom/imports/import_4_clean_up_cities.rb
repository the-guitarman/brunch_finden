def start
  City.find_each({:batch_size => GLOBAL_CONFIG[:find_each_batch_size]}) do |city|
#    other_cities = City.find(:all, {
#      :conditions => ["id <> ? AND name = ? AND state_id = ?",
#        city.id, city.name, city.state_id]
#    })
    other_cities = City.find(:all, {
      :conditions => ["id <> ? AND name = ?",
        city.id, city.name]
    })
    other_cities.each do |other_city|
      if other_city.number_of_locations <= 0
        other_city.destroy
        print 'd'
      else
        print '.'
      end
    end
  end
end

start