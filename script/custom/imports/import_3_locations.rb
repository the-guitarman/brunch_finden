require 'csv'
require 'money'

format = I18n.t(:'number.currency.format', :raise => true) rescue {}
CS = format[:separator]
CD = "\\#{format[:delimiter]}"
CP = format[:precision]

IMPORT_CSV_FILE = "#{Rails.root}/tmp/Beispieldatei.csv"
SKIP_HEAD_ROWS = 1
META = {
  :seperator => ";"
}
FORMAT = {
#  :stadt         => 0,
  :name          => 1,
  :price         => 2,
  :brunch_time   => 3,
  :service       => 4,
  :street        => 5,
  :zip_code      => 6,
  :ort           => 7,
  :phone         => 8,
  :email         => 9,
  :website       => 10,
  :opening_hours => 11,
  :description   => 12,
  :comment       => 13
}
STATISTICS = {
  :lines_total  => 0,
  :lines_ok     => 0,
  :lines_broken => 0,
  :locations    => 0
}
LOG_FILE = "#{Rails.root}/log/import_locations_#{Time.now.strftime("%Y%m%d%H%M%S")}.log"
money_symbol = Money::Currency::TABLE.map{|el| el[1][:symbol].to_s}
money_symbol.compact!
MONEY_SYMBOL = money_symbol.map{|el| el.downcase}

money_iso_code = Money::Currency::TABLE.map{|el| el[1][:iso_code].to_s}
money_iso_code.compact!
MONEY_ISO_CODE = money_iso_code.map{|el| el.downcase}

money_name = Money::Currency::TABLE.map{|el| el[1][:name].to_s}
money_name.compact!
MONEY_NAME = money_name.map{|el| el.downcase}

def parse_csv(file)
  print "\nParsing file ..."
  # skip head row
  (1..SKIP_HEAD_ROWS).each do
    file.readline unless file.eof?
  end
  # read lines
  while file.eof == false
    STATISTICS[:lines_total] += 1
    #line = strip_tags(file.readline)
    line = file.readline
    if file.eof == false and line.count('"').odd?
      line += file.readline
    end
    begin
      CSV::Reader.parse(line, META[:seperator]) do |row|
        meta_data = parse_csv_row(row)
        yield meta_data, line if block_given?
      end
      STATISTICS[:lines_ok] += 1
    rescue CSV::IllegalFormatError => e
      puts e.message + ' - ' + line
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

def print_status
  puts "\nStatus: "
  STATISTICS.each do |key, value|
    puts "#{key}: #{value}"
  end
end

def start
  if File.exist?(IMPORT_CSV_FILE)

    block = lambda do |meta_data, line|
      values_array = meta_data.values
      values_array.compact!
      unless values_array.empty?
        zipcode = nil
        zip_codes = ZipCode.find(:all, {:conditions => {:code => meta_data[:zip_code].strip}})
        zip_codes.each do |zc|
          if zc.city.name.include?(meta_data[:ort].strip)
            zipcode = zc.dup
            break
          end
        end

        if zipcode.blank?
          if zip_code = ZipCode.find_by_code(meta_data[:zip_code].strip)
            city = City.create({
              :state_id => zip_code.city.state_id,
              :name     => meta_data[:ort]
            })
            unless city.new_record?
              zipcode = ZipCode.create({
                :city_id => city.id,
                :code => zip_code.code
              })
            end
          end
        end

        unless zipcode.blank?
          domain_name = CustomConfigHandler.instance.frontend_config['DOMAIN']['NAME'].downcase
          fu = FrontendUser.find_byemail("info@#{domain_name}")
          location = Location.new({:zip_code_id => zipcode.id, :frontend_user => fu})
          location.published = true
          location.name = meta_data[:name]
          unless meta_data[:price].blank?
            price_match = meta_data[:price].match(/[-\+]{0,1}((\d*)|(\d{0,3}(#{CD}\d{3})*))#{CS}\d{0,#{CP}}/)
            unless price_match.to_s.blank?
              location.amount_field_price = price_match.to_s
            end

            price_array = meta_data[:price].downcase.split(' ')
            price_array.each_with_index do |word, index|
              unless word.to_f > 0
                word_downcased = word.downcase
                if MONEY_ISO_CODE.include?(word_downcased) or
                   MONEY_SYMBOL.include?(word_downcased) or
                   MONEY_NAME.include?(word_downcased)
                  index.downto(0) do |index|
                    price_array.delete_at(index)
                  end
                  break
                end
              end
            end

            price_information = price_array.join(' ')
            unless price_information == location.amount_field_price
              location.price_information = price_information
            end
          end
          location.brunch_time = meta_data[:brunch_time]
          location.service = meta_data[:service]
          street = meta_data[:street].split('|')
          street.delete_if{|s| s.blank?}
          unless street.empty?
            location.street = street.first
          end
          location.phone = meta_data[:phone]
          unless meta_data[:email].blank?
            location.email = meta_data[:email].gsub(' ', '').gsub('(at)', '@')
          end
          unless meta_data[:website].blank?
            begin
              uri = URI.parse(meta_data[:website])
              if uri.scheme.blank?
                url = 'http://' + uri.to_s
              else
                url = uri.to_s
              end
              location.website = url
            rescue Exception => e
              puts "Error: #{e.message}"
  #            puts e.backtrace.join("\n")
            end
          end
          unless meta_data[:opening_hours].blank?
            unless meta_data[:opening_hours].start_with?('?')
              opening_hours = meta_data[:opening_hours].split('|')
              opening_hours = opening_hours.map{|el| el.strip}
              location.opening_hours = opening_hours.join("\n")
            end
          end

          location.description = meta_data[:description]

          location.save



          unless location.errors.empty?
            errors = line + "\n"
            errors = meta_data.inspect + "\n"
            location.errors.each do |k,v|
              errors += "#{k}: #{v}\n"
            end
            errors += "\n"
            append_to_log_file(errors)
          end
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

def append_to_log_file(text)
  File.open(LOG_FILE, 'a') do |f|
    f.puts(text)
  end
end

start
