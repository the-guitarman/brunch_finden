# encoding: UTF-8

#require 'fileutils'
require 'csv_parser'
require 'money'

module LocationImporter
  def self.run(file_to_import)
    if File.exist?(file_to_import)
      meta_locations = []
      block = lambda do |line_array|
        meta_location = MetaLocation.instance.create(line_array)
        meta_locations.push(meta_location)
      end
      CsvParser.new.parse(file_to_import, &block)
      unless meta_locations.empty?
        Base.new.import_all(meta_locations)
        Base.append_to_log_file(Location.reindex)
      end
    end
  end
  
  class Base
    format = I18n.t(:'number.currency.format', :raise => true) rescue {}
    CS = format[:separator]
    CD = "\\#{format[:delimiter]}"
    CP = format[:precision]
    
    LOG_FILE = "#{Rails.root}/log/import_locations_#{Time.now.strftime("%Y%m%d%H%M%S")}.log"
#    money_symbol = Money::Currency::TABLE.map{|el| el[1][:symbol].to_s}
#    money_symbol.compact!
#    MONEY_SYMBOL = money_symbol.map{|el| el.downcase}
#    
#    money_iso_code = Money::Currency::TABLE.map{|el| el[1][:iso_code].to_s}
#    money_iso_code.compact!
#    MONEY_ISO_CODE = money_iso_code.map{|el| el.downcase}
#    
#    money_name = Money::Currency::TABLE.map{|el| el[1][:name].to_s}
#    money_name.compact!
#    MONEY_NAME = money_name.map{|el| el.downcase}

    def initialize
      ThinkingSphinx.deltas_enabled = false
    end

    def import_all(meta_locations)
      puts "Importing #{meta_locations.count} locations ..."
      meta_locations.each do |meta_location|
        import(meta_location)
      end
      puts "Import finished."
    end
    
    def import(meta_location)
      @location_count ||= 0
      @location_count += 1
#      puts "-- #{@location_count}: meta_location: #{meta_location.inspect}"
      
      values_array = meta_location.values
      values_array.compact!
      unless values_array.empty?
        zipcode   = nil
        city_name = meta_location.delete(:city).strip
        zip_code  = meta_location.delete(:zip_code).strip
        if Rails.version >= '3.0.0'
          zip_codes = ZipCode.where({:code => zip_code})
        else
          zip_codes = ZipCode.find(:all, {:conditions => {:code => zip_code}})
        end
#        puts "-- #{@location_count}: zip_codes: #{zip_codes.count}"
        if zip_codes.count == 1
          zipcode = zip_codes.first
        else
          zip_codes.each do |zc|
            if zc.city.name.include?(city_name)
              zipcode = zc.dup
              break
            end
          end
        end

        if zipcode.blank? and city_name
          puts "-- #{@location_count}: zip code blank, but city name given"
          if tmp_zip_code = ZipCode.find_by_code(zip_code)
 #           puts "-- #{@location_count}: tmp_zip_code found"
            if Rails.version >= '3.0.0'
              city = City.where({
                       :state_id => tmp_zip_code.city.state_id,
                       :name     => city_name
                     }).first
            else
              city = City.find(:first, {:conditions => {
                       :state_id => tmp_zip_code.city.state_id,
                       :name     => city_name
                     }})
            end
            unless city
              city = City.create({
                :state_id => tmp_zip_code.city.state_id,
                :name     => city_name
              })
            end
            unless city.new_record?
              zipcode = ZipCode.create({
                :city_id => city.id,
                :code => tmp_zip_code.code
              })
            end
          end
        end
        
        if zipcode.blank?
          puts "-- #{@location_count}: zip code #{zip_code} within #{city_name} not found."
          puts "-- #{@location_count}: #{meta_location.inspect}"
        else
          if Rails.version >= '3.0.0'
            location = Location.where({
                         :name => meta_location[:name],
                         :zip_code_id => zipcode.id
                       })
          else
            location = Location.find(:first, {:conditions => {
                         :name => meta_location[:name],
                         :zip_code_id => zipcode.id
                       }})
          end
          if location
            puts "-- #{@location_count}: Location imported already: #{meta_location[:name]}" 
            return true
          end
          
          location = Location.new(meta_location)
          location.zip_code_id = zipcode.id
          domain_name = CustomConfigHandler.instance.frontend_config['DOMAIN']['NAME'].downcase
          domain_name = 'brunch-finden.de' if Rails.env.development?
          fu = FrontendUser.find_by_email("info@#{domain_name}")
          location.frontend_user = fu
          location.published = true
          location.general_terms_and_conditions_confirmed = true
          
          unless meta_location[:price].blank?
            price_match = meta_location[:price].match(/[-\+]{0,1}((\d*)|(\d{0,3}(#{CD}\d{3})*))#{CS}\d{0,#{CP}}/)
            unless price_match.to_s.blank?
              location.amount_field_price = price_match.to_s
            end

#            price_array = meta_location[:price].downcase.split(' ')
#            price_array.each_with_index do |word, index|
#              unless word.to_f > 0
#                word_downcased = word.downcase
#                if MONEY_ISO_CODE.include?(word_downcased) or
#                   MONEY_SYMBOL.include?(word_downcased) or
#                   MONEY_NAME.include?(word_downcased)
#                  index.downto(0) do |index|
#                    price_array.delete_at(index)
#                  end
#                  break
#                end
#              end
#            end
#
#            price_information = price_array.join(' ')
#            unless price_information == location.amount_field_price
#              location.price_information = price_information
#            end
          end
          
          unless meta_location[:website].blank?
            begin
              uri = URI.parse(meta_location[:website])
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
          
          unless location.valid?
            puts "-- #{@location_count}: errors: #{location.name} -> #{location.errors.map{|k,v| [k,v, location.send(k.to_sym)]}.inspect}"
          else
            location.save
            puts "-- #{@location_count}: Location #{location.name} imported newly."
          end
#          puts "-- #{@location_count}: price: l:#{location.price}, ml:#{meta_location[:price]}"

          unless location.errors.empty?
            errors = meta_location.inspect + "\n"
            location.errors.each do |k,v|
              errors += "#{k}: #{v}\n"
            end
            errors += "\n"
            append_to_log_file(errors)
          end
        end
      end
    end
    
    def self.append_to_log_file(text)
      File.open(LOG_FILE, 'a') do |f|
        f.puts(text)
      end
    end
  end
  
  class MetaLocation
    include Singleton
    
    #0"Stadt";
    #1"PLZ";
    #2"Straße + Hausnummer";
    #3"Name der Location";
    #4"Preis pro Person ";
    #5"Infos zum Preis";
    #6"Telefon";
    #7"Fax";
    #8"E-Mail";
    #9"Webseite";
    #10"Öffnungszeiten";
    #11"Brunch-Zeiten";
    #12"Service";
    #13"Beschreibung";
    #14"Ansprechpartner";
    #15"Status"
    
    FORMAT = {
      :city              => 0,
      :zip_code          => 1,
      :street            => 2,
      :name              => 3,
      :price             => 4,
      :price_information => 5,
      :phone             => 6,
      :fax               => 7,
      :email             => 8,
      :website           => 9,
      :opening_hours     => 10,
      :brunch_time       => 11, 
      :service           => 12,
      :description       => 13#,
      #:contact_person    => 14,
      #:status            => 15
    }
    
    def create(line_array)
      attributes = {}
      FORMAT.each_pair do |attribute, column_index|
        attributes[attribute] = line_array[column_index.to_i] if column_index
      end
      return attributes
    end
  end
end
