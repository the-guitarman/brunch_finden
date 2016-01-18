module ProcessTime
  def running_time(number_of_seconds)
    number_of_seconds = number_of_seconds.to_i
    min = number_of_seconds / 60 % 60
    if number_of_seconds >= 3600
      running = [number_of_seconds / 3600, min].map do |t|
        t.to_s.rjust(2, '0')
      end.join(':')
      running << ' hh:mm'
    else
      sec = (number_of_seconds - min * 60)
      if sec > 0
        sec = (sec % 60).to_i
      else
        sec = 0
      end
      running = [min, sec].map do |t|
        t.to_s.rjust(2, '0')
      end.join(':')
      running << ' mm:ss'
    end
    running
  end

  def format_decimals(number, decimals = 2)
    format("%.#{decimals}f",number)
  end

  def rjust(value, length = 5)
    value.to_s.rjust(length)
  end
end
