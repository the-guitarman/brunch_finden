require 'csv'

IMPORT_CSV_FILE = "#{Rails.root}/tmp/plz_bundesland.txt"

STATISTICS = {
  :lines_total  => 0,
  :lines_ok     => 0,
  :states       => 0,
  :cities       => 0,
  :zip_codes    => 0
}

def read_file(file)
  print "\nParsing file ..."
  while file.eof == false
    STATISTICS[:lines_total] += 1
    line = file.readline
    yield line if block_given?
    print 'L'
  end
  puts ' done!'
end

def print_status
  puts "\nStatus: "
  STATISTICS.each do |key, value|
    puts "#{key}: #{value}"
  end
end

def start
  if File.exist?(IMPORT_CSV_FILE)
    block = lambda do |line|
      unless line.blank?
        line_array = line.split(' ')
        if line_array.length > 1
          zip_codes_array = line_array.first.split('-')
          if zip_codes_array.length == 2
            zip_codes = ZipCode.find(:all,
              :conditions => "code >= '#{zip_codes_array.first}' and code <= '#{zip_codes_array.last}'"
            )
            state = State.find_by_name(line_array.last)
            if state
              zip_codes.each do |zip_code|
                city = zip_code.city
                if city.state_id != state.id
                  city_exists = City.find(:first, {
                    :conditions => {:name => city.name, :state_id => state.id}
                  })
                  unless city_exists
                    city.update_attributes({:state_id => state.id})
                    print 'U'
                  else
                    city.destroy
                    print 'D'
                  end
                else
                  print 'z'
                end
              end
              STATISTICS[:lines_ok] += 1
            end
          end
        end
      end
    end

    File.open(IMPORT_CSV_FILE, 'r') do |f|
      read_file(f, &block)
    end

    print_status
  else
    puts "Error: No file found: #{IMPORT_CSV_FILE}"
  end
end

start
