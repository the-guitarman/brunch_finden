BATCH_SIZE = GLOBAL_CONFIG[:find_each_batch_size]

print "\n"

# Temporarily disable delta indexing, 
# then perform a single rebuild of index at the end.
ZipCode.suspended_delta do
  puts I18n.l(Time.now) 
  print "Count locations for each zip code ... "
  ZipCode.find_each({
    :select => 'id, number_of_locations',
    :conditions => "number_of_locations > 0", 
    :batch_size => BATCH_SIZE
  }) do |zip_code|
    counter = zip_code.locations.count({:conditions => {:published => true}})
    unless zip_code.number_of_locations == counter
      zip_code.update_attributes({:number_of_locations => counter})
    end
  end
  puts "done!"
  puts I18n.l(Time.now) 
end


sleep 10
print "\n\n\n"


City.suspended_delta do
  puts I18n.l(Time.now) 
  print "Count locations for each city ... "
  City.find_each({
      :select => 'id, number_of_locations', 
      :conditions => "number_of_locations > 0", 
      :batch_size => BATCH_SIZE
  }) do |city|
    counter = 0
    city.zip_codes.find_each({
      :select => 'id, number_of_locations', 
      :conditions => "number_of_locations > 0",
      :batch_size => BATCH_SIZE
    }) do |zip_code|
      counter += zip_code.number_of_locations
    end
    unless city.number_of_locations == counter
      city.update_attributes({:number_of_locations => counter})
    end
  end
  puts "done!"
  puts I18n.l(Time.now) 
end


sleep 10
print "\n\n\n"


puts I18n.l(Time.now) 
print "Count locations for each city char ... "
CityChar.find_each({
    :select => 'id, number_of_locations', 
    :conditions => "number_of_locations > 0", 
    :batch_size => BATCH_SIZE
}) do |city_char|
  counter = 0
  city_char.cities.find_each({
    :select => 'id, number_of_locations', 
    :conditions => "number_of_locations > 0",
    :batch_size => BATCH_SIZE
  }) do |city|
    counter += city.number_of_locations
  end
  unless city_char.number_of_locations == counter
    city_char.update_attributes({:number_of_locations => counter})
  end
end
puts "done!"
puts I18n.l(Time.now) 


sleep 10
print "\n\n\n"


puts I18n.l(Time.now)
print "Count locations for each state ... "
State.find_each({
  :select => 'id, number_of_locations',
  :conditions => "number_of_locations > 0",
  :batch_size => BATCH_SIZE
}) do |state|
  counter = 0
  state.cities.find_each({
    :select => 'id, number_of_locations', 
    :conditions => "number_of_locations > 0", 
    :batch_size => BATCH_SIZE
  }) do |city|
    counter += city.number_of_locations
  end
  unless state.number_of_locations == counter
    state.update_attributes({:number_of_locations => counter})
  end
end
puts "done!"
puts I18n.l(Time.now)

# Perform a single rebuild of index now.
#Product.reindex

# Don't write any delta indexing output to the log.
#ThinkingSphinx.suppress_delta_output = true