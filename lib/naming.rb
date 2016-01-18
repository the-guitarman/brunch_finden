module Naming
  
  def self.seo_name(record)
    seo_name=""
    prd_name_parts=seo_transformed_array(record.name)
    word_count=5
    if record.respond_to?(:manufacturer) and record.manufacturer
      mfr_name_parts=seo_transformed_array(record.manufacturer.name)
      if mfr_name_parts.size==1
        seo_name<<mfr_name_parts[0]
        word_count-=1
      elsif mfr_name_parts.size>1
        seo_name<<mfr_name_parts[0]+"-";seo_name<<mfr_name_parts[1]
        word_count-=2
      end
    end
    prd_name_parts.each do |part|
      seo_name<<"-"+part if word_count>=0
      word_count-=1
    end
    return seo_name
  end
  
  
  # returns product's manufacturer name or an empty string if not set
  def self.manufacturer_name(product)
      if product.manufacturer
        return  product.manufacturer.name
      else
        return ''
      end
  end
private
  #TODO:5 ÄÖÜß to AE OE UE ss?
  def self.seo_transformed_array(string)
    string.downcase.tr("!\"§$%&/()=?#'+*~.,:;@€<|>{[]}","").split
  end
end