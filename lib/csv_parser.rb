# encoding: UTF-8

require 'csv'

class CsvParser
  attr_reader :statistics, :exceptions
  
  def initialize(csv_seperator = ';', csv_string = '"', skip_head = 1)
    @csv_seperator = csv_seperator
    @csv_string = csv_string
    @skip_head = skip_head
    @statistics = {
      :lines_total  => 0,
      :lines_ok     => 0,
      :lines_broken => 0
    }
    @exceptions = []
    @html_coder = HTMLEntities.new
  end

  def parse(file_to_parse, &block)
    ret = []
    charset = File.charset(file_to_parse)
    File.open(file_to_parse,"r:#{charset}") do |file|
      begin
        ret = parse_csv(file, &block)
      ensure
        file.close unless file.closed?
      end
    end
    print_statistics
    print_exceptions
    return ret
  end

  private

  def parse_csv(file)
    line_arrays = []
    print "\nParse csv..."
    (1..@skip_head).each {file.readline unless file.eof?}
    while file.eof == false
      line = file.readline
      line = line.gsub("\n", "").gsub("\r", "").strip
      next if line.blank?
      @statistics[:lines_total] += 1
      if @csv_string.blank?
        line_array = line.split(@csv_seperator)
        @statistics[:lines_ok] += 1
      else
        begin
          if Rails.version >= '3.0.0'
            line_array = CSV.parse_line(line, {:col_sep => @csv_seperator, :quote_char => @csv_string})
          else
            line_array = CSV.parse_line(line, @csv_seperator) #, @csv_string)
          end
          @statistics[:lines_ok] += 1
        rescue CSV::MalformedCSVError => e
          @statistics[:lines_broken] += 1
          @exceptions.push(e)
          next
        end
      end
      line_array.map! do |value| 
        if value.is_a?(String)
          @html_coder.decode(@html_coder.encode(value, :named).gsub(/&nbsp;/, '').strip)
        else
          value
        end
      end
      if block_given?
        yield(line_array)
      else
        line_arrays.push(Array.new(line_array))
      end
    end
    puts 'done!'
    return line_arrays
  end
  
  def print_statistics
    puts "\nStatus: "
    @statistics.each do |key, value|
      puts "#{key}: #{value}"
    end
  end
  
  def print_exceptions
    @exceptions.each do |e|
      puts "EXCEPTION:\nMessage:#{e.message}\nBacktrace:#{e.backtrace.join("\n")}\n\n"
    end
  end
end