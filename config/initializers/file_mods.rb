# Extensions for File class.
class File
  # Returns mimetype of filename.
  # if file has "text/plain; charset=utf-8\n",
  # it will return "text/plain"
  def File.mimetype(filename)
    `file -ib #{filename}`.split(";")[0]
  end

  # Returns charset of filename.
  # if file has "text/plain; charset=utf-8\n",
  # it will return "utf-8"
  def File.charset(filename)
    temp = `file -ib #{filename}`.split(";")[1].chomp.strip
    temp.split('=')[1]
  end

  # Returns the number of lines in a file.
  # This could be slow for very large files,
  # and pushes the load to increase very fast.
  def File.count_lines(filename)
    temp = `wc -l #{filename}`
    temp.split(' ')[0].to_i
  end

  # Returns the estimated number of lines in a file.
  # This is a projection only. Its calculated at an average
  # of the byte sizes of the first ten file lines and the file size.
  def File.estimated_lines_count(filename)
    return 0 unless File.size?(filename)
    size = File.size(filename)
    avg_line_size = 0
    counter = 0
    File.open(filename, 'r') do |f|
      10.times do
        unless f.eof
          line = f.readline
          unless line.blank?
            avg_line_size += line.bytesize
            counter += 1
          end
        end
      end
    end
    return 0 unless avg_line_size > 0
    avg_line_size = avg_line_size.to_f / counter
    lines_count_f = size.to_f / avg_line_size
    lines_count_i = lines_count_f.to_i
    lines_count_i += 1 if lines_count_f > lines_count_i
    return lines_count_i
  end
end