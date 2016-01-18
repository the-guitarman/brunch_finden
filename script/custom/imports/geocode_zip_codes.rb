def start
  ZipCode.find_each({:batch_size => GLOBAL_CONFIG[:find_each_batch_size]}) do |zip_code|
    zip_code.geocode
    sleep 59
  end
end

start
