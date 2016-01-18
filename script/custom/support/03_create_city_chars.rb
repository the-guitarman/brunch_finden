def start
  puts "Create city chars ..."
  ThinkingSphinx.deltas_enabled = false
  ThinkingSphinx.suppress_delta_output = true
  City.find_each({:batch_size => GLOBAL_CONFIG[:find_each_batch_size]}) do |city|
    city.save #.send(:check_for_city_char)
    print '.'
  end
  ThinkingSphinx.suppress_delta_output = false
  ThinkingSphinx.deltas_enabled = true
  print ' done!'
end

start