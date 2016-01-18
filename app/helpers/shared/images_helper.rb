#encoding: utf-8
module Shared::ImagesHelper
  TEXT_LINES = 2
  
  private

  def prepare_logo_text(text, size)
    mtl = max_line_length(size)
    text = truncate(text, {:length => mtl * TEXT_LINES})
    text = word_wrap(text, {:line_width => mtl})
    return text
  end
  
  def font_size(size)
    height = size.split('x').last.to_i
    return height / (TEXT_LINES + 1)
  end
  
  def max_line_length(size)
    width = size.split('x').first.to_i
    return ((width / font_size(size)) * TEXT_LINES).to_i
  end
end
