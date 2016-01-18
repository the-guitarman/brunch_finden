# check defined environments log files and truncates it,
# if file size is too large or file is to old.

MAX_LOG_FILE_SIZE = 2.megabytes
MAX_LOG_FILE_AGE = 7 # days
CHECK_FOR_ENVIRONMENTS = ['development', 'test']

def truncate_file(file_name, reason)
  File.truncate(file_name, 0)
  File.open(file_name, 'w') do |f|
    f.puts("Logfile truncated to zero size on #{Time.now}")
  end
  puts "=> #{reason} Log file truncated!"
end

def log_file_age_is_reached(file_name)
  ret = false
  if File.size(file_name) > 0
    File.open(file_name, 'r') do |f|
      unless f.eof?
        line = f.readline
        date_time_array = line.scan(/(Sun|Mon|Tue|Wed|Thu|Fri|Sat) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) (\d\d) (\d\d):(\d\d):(\d\d) .{5} (\d\d\d\d)/)
        unless date_time_array.empty?
          dta = date_time_array.first
          begin
            date_time = Time.mktime(dta.last, dta[1], dta[2], dta[3], dta[4], dta[5]).to_date
            if date_time < (Time.now.to_date - MAX_LOG_FILE_AGE)
              truncate_file(file_name, "It's #{Time.now.strftime('%A')} and the log file is older than 7 days.")
              ret = true
            end
          rescue
            ret = false
          end
        end
      end
    end
  else
    truncate_file(file_name, "It's #{Time.now.strftime('%A')} and the log file had zero size.")
  end
  return ret
end

if CHECK_FOR_ENVIRONMENTS.include?(Rails.env)
  file_name = "#{Rails.root}/log/#{Rails.env}.log"
  if File.exist?(file_name)
    if File.size(file_name) > MAX_LOG_FILE_SIZE
      truncate_file(file_name, 'Log file has reached max file size.')
    else
      log_file_age_is_reached(file_name)
    end
  end
end