class FormatString
  CHARSET_MAP = {'À' => 'A', 'Á' => 'A', 'Â' => 'A', 'Ã' => 'A', 'Ä' => 'A',
    'Å' => 'A', 'Æ' => 'Ae', 'Ç' => 'C', 'È' => 'E', 'É' => 'E',
    'Ê' => 'E', 'Ë' => 'E', 'Ì' => 'I', 'Í' => 'I', 'Î' => 'I', 'Ï' => 'I',
    'Ñ' => 'N', 'Ò' => 'O', 'Ó' => 'O', 'Ô' => 'O', 'Õ' => 'O', 'Ö' => 'Oe',
    'Ø' => '0', 'Ù' => 'U', 'Ú' => 'U', 'Û' => 'U', 'Ü' => 'Ue', 'Ý' => 'Y',
    'ß' => 'ss', 'à' => 'a', 'á' => 'a', 'â' => 'a', 'ã' => 'a', 'ä' => 'ae',
    'å' => 'a', 'æ' => 'ae', 'ç' => 'c', 'è' => 'e', 'é' => 'e', 'ê' => 'e',
    'ë' => 'e', 'ì' => 'i', 'í' => 'i', 'î' => 'i', 'ï' => 'i', 'ñ' => 'n',
    'ò' => 'o', 'ó' => 'o', 'ô' => 'o', 'õ' => 'o', 'ö' => 'oe', 'ø' => 'o',
    'ù' => 'u', 'ú' => 'u', 'û' => 'u', 'ü' => 'ue', 'ý' => 'y', 'ÿ' => 'y'}

  def self.normalize_charset(str)
    ret = str
    CHARSET_MAP.each do |key, val|
      ret.gsub!(key, val)
    end
    ret
  end

  def self.normalize_charset!(str)
    CHARSET_MAP.each do |key, val|
      str.gsub!(key, val)
    end
  end

  def self.remove_special_characters(str)
    str.tr("!\"§$%&/()=?#'+*~.,:;@€<|>{[]}",'')
  end

  def self.remove_special_characters!(str)
    str.tr!("!\"§$%&/()=?#'+*~.,:;@€<|>{[]}",'')
  end
end
