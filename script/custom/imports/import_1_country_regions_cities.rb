require 'csv'

IMPORT_CSV_FILE = "#{Rails.root}/tmp/de.tab"
KEYS = {
  :state => 'Bundesland'
}
META = {
  :seperator => "\t"
}
FORMAT = {
  :key       => 12,
  :name      => 3,
  :zip       => 7,
  :lat       => 4,
  :lng       => 5,
  :area_code => 8
}
STATISTICS = {
  :lines_total  => 0,
  :lines_ok     => 0,
  :lines_broken => 0,
  :states       => 0,
  :cities       => 0,
  :zip_codes    => 0
}

def parse_csv(file)
  print "\nParsing file ..."
  while file.eof == false
    STATISTICS[:lines_total] += 1
    #line = strip_tags(file.readline)
    line = file.readline
    begin
      CSV::Reader.parse(line, META[:seperator]) do |row|
        meta_data = parse_csv_row(row)
        yield meta_data if block_given?
      end
      STATISTICS[:lines_ok] += 1
    rescue CSV::IllegalFormatError => e
      STATISTICS[:lines_broken] += 1
    end
    print '.'
  end
  puts ' done!'
end

def parse_csv_row(row)
  meta_data = {}
  FORMAT.each_pair do |attribute, column_index|
    meta_data[attribute] = row[column_index.to_i] if column_index
  end
  return meta_data
end

def save_geo_code(options = {})
  if object = options[:object]
#    puts "\n #{options.inspect}"
    if options[:lat] and options[:lat].is_numeric?({:decimals => true}) and
       options[:lng] and options[:lng].is_numeric?({:decimals => true})
      geo_location = if object.geo_location.nil?
          GeoLocation.new({:geo_code => object})
      else
        object.geo_location
      end
      geo_location.lat = options[:lat]
      geo_location.lng = options[:lng]
      geo_location.save
#      unless object.geo_location.errors.blank?
#        puts object.geo_location.errors.inspect
#      end
    end
  end
end

def print_status
  puts "\nStatus: "
  STATISTICS.each do |key, value|
    puts "#{key}: #{value}"
  end
end

def start
  if File.exist?(IMPORT_CSV_FILE)
    @current = {:state => '', :city  => ''}

    block = lambda do |meta_data|
#      puts meta_data[:key].to_i
      if meta_data[:key].to_s.strip == KEYS[:state]
        @current[:state] = meta_data[:name]
        state = State.find_or_create(@current[:state])
        if state.errors.empty?
          STATISTICS[:states] += 1
        else
          #logger.error state.errors.inspect
        end
      elsif not @current[:state].blank? and not meta_data[:zip].blank?
        city = City.find_or_create(meta_data[:name], @current[:state])
        if city.errors.empty?
          STATISTICS[:cities] += 1
        else
          #logger.error city.errors.inspect
        end
#        save_geo_code({
#          :object => city, :lat => meta_data[:lat], :lng => meta_data[:lng]
#        })
        zip_codes = meta_data[:zip].to_s.split(',')
        zip_codes.each do |code|
          code = "0#{code}" if code.length == 4
          zip_code = ZipCode.find_or_create(code, city.name, @current[:state])
          if zip_code.errors.empty?
            STATISTICS[:zip_codes] += 1
          else
            #logger.error zip_code.errors.inspect
          end
#          save_geo_code({
#            :object => zip_code, :lat => meta_data[:lat], :lng => meta_data[:lng]
#          })
        end
        
      end
    end

    File.open(IMPORT_CSV_FILE, 'r') do |f|
      parse_csv(f, &block)
    end

    print_status
  else
    puts "Error: No file found: #{IMPORT_CSV_FILE}"
  end
end

start
