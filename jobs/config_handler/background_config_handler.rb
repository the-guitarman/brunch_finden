# encoding: UTF-8

class BackgroundConfigHandler
  include ConfigHandler
  acts_as_config_handler(
    "#{Rails.root}/config/background/#{Rails.env}/",
    {
      :model_config => :yml, 
      :coupon_handler_config => :yml, 
      :coupon_fetcher_config => :yml, 
      :coupon_parser_config  => :yml,
      :coupons4u_de_xml_format_detailed => :yml
    },
    {}
  )
end
