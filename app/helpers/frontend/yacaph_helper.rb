module Frontend::Yacaph
   def self.random_image
      @files ||= Dir.entries("#{Rails.root}/public/images/captcha")[2..-1]
      @files[rand(@files.size)]
   end
end

module Frontend::YacaphHelper
   
   def yacaph_image
      @yacaph_image ||= Frontend::Yacaph::random_image
      image_tag('captcha/' + @yacaph_image)
   end
   
   def yacaph_label(label)
     content_tag('label', label, :for => 'captcha')
   end
   
   def yacaph_text(options = {})
     @yacaph_image ||= Frontend::Yacaph::random_image
     text_field_tag(:captcha, nil, options)
   end
   
   def yacaph_input_text(label)
      yacaph_label(label) + yacaph_text
   end
   
   def yacaph_hidden_text
      @yacaph_image ||= Frontend::Yacaph::random_image
      hidden_field_tag(:captcha_validation, @yacaph_image.gsub(/.png$/,''))
   end
   
   def yacaph_block(label = 'Please type the characters in the image below')
      content_tag('div', yacaph_hidden_text + yacaph_input_text(label) + yacaph_image, {:class => 'yacaph'})
   end
   
   def yacaph_validated?
      text3 = Yacaph::encrypt_string(params[:captcha] || '') == params[:captcha_validation]
   end
end