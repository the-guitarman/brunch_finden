#module Mixins::SwitchToMobile
#  MOBILE_BROWSERS = [
#    "android", "ipod", "opera mini", "blackberry", "palm","hiptop","avantgo",
#    "plucker", "xiino","blazer","elaine", "windows ce; ppc;",
#    "windows ce; smartphone;","windows ce; iemobile", "up.browser","up.link",
#    "mmp","symbian","smartphone", "midp","wap","vodafone","o2","pocket",
#    "kindle", "mobile","pda","psp","treo"
#  ]
#  
#  def self.included(controller)
#    controller.before_filter(:check_for_mobile_device)
#  end
#  
#  private
#  
#  # download Google Android emulator 
#  # http://www.arctickiwi.com/blog/mobile-enable-your-ruby-on-rails-site-for-small-screens
#  def check_for_mobile_device
#    if session[:homepage].blank?
#      if self.is_a?(Frontend::FrontendController)
#        if agent = request.headers["HTTP_USER_AGENT"]
#          #puts "----------------------------- agent: #{agent}"
#          agent.downcase!
#          MOBILE_BROWSERS.each do |m|
#            if agent.match(m)
#              redirect_to mobile_url
#              return true
#            end
#          end
#        end
#      end
#    end
#  end
#
##  def set_layout
##    session["layout"] = (params[:mobile] == "1" ? "mobile" : "normal")
##    redirect_to root_url
##  end
##
##  def selected_layout
##    session.inspect # force session load
##    if session.has_key?('layout')
##      return (session['layout'] == 'mobile_phone') ? 'mobile_phone' : 'standard'
##    end
##    return nil
##  end
#end