# encoding: UTF-8

class CustomConfigHandler
  include ConfigHandler
  acts_as_config_handler(
    "#{Rails.root}/config/custom/#{Rails.env}/",
    {
      :frontend_header_data_config => :yml, 
      :new_frontend_header_data_config => :yml, 
      :frontend_config => :yml, 
      :backend_config  => :yml, 
      :bad_words => :yml, 
      :blacklist => :yml
    },
    {
      :advertising_opportunities => :txt, 
      :blacklisted_email_domains => :yml,
      :robots_txt_config => :yml
    }
  )

#  def in_use?(link)
#    {
#      TOP_MENU_ITEMS_FILE   => top_menu_items,
#      START_CATEGORIES_FILE => start_categories,
#      LIST1_FILE => list1,
#      LIST2_FILE => list2
#    }.each do |file_name, item|
#      if find_link(item, link)
#        return "Link found in "+file_name
#      end
#    end
#    return false
#  end
  
  def add_frontend_header_data_config(data)
    fc = frontend_config
    text = ''
    unless File.exist?("#{files_path}frontend_header_data_config.yml")
      text = [
        "# This file contains header data,\n",
        "# that could not be found in frontend_header_data_config.yml.\n",
        "# So please remove it from this file, edit it and insert it into frontend_header_data_config.yml.\n",
        "\n"
      ].join
    end
    text += data.ya2yaml({:indent_size => 2})
    unless fc['DOMAIN']['FULL_NAME'].blank?
      text.gsub!(/#{fc['DOMAIN']['FULL_NAME']}/, '__DOMAIN_FULL_NAME__')
    end
    unless fc['DOMAIN']['NAME'].blank?
      text.gsub!(/#{fc['DOMAIN']['NAME']}/, '__DOMAIN_NAME__')
    end
    File.open("#{files_path}frontend_header_data_config.yml", "a") do |f|
      f.puts(text)
    end
    frontend_header_data_config(true)
  end
end
