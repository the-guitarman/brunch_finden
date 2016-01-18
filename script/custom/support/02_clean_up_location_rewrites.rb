def start
  puts "Clean up city rewrite ..."
  Location.find_each({:batch_size => GLOBAL_CONFIG[:find_each_batch_size]}) do |location|
    location.update_attributes({:rewrite => nil})
    print '.'
  end
  print ' done!'

  Forwarding.delete_all
end

start