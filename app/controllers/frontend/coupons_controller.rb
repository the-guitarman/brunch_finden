class Frontend::CouponsController < Frontend::FrontendController
  caches_page :index
  
  before_filter :set_coupon_merchant, :only => :all_merchant_coupons
#  caches_action :all_merchant_coupons, 
#    :cache_path => proc{|c| 
#      parameters = (c.params || {}).copy
#      parameters.delete(:utf8)
#      coupon_merchant = c.instance_variable_get(:@coupon_merchant)
#      parameters.merge!({:date => coupon_merchant.updated_at.to_i})
#      return parameters
#    }
  caches_page :all_merchant_coupons, :cache_path => :cache_merchant_coupons_path.to_proc
  
  caches_action :all_coupon_merchants, 
    :cache_path => proc{|c| 
      parameters = (c.params || {}).copy
      parameters.delete(:utf8)
      last_update_at = BackgroundConfigHandler.instance.coupon_fetcher_config['LAST_RESET']
      unless last_update_at.blank?
        parameters.merge!({:date => Time.parse(last_update_at).to_i})
      end
      return parameters
    }
  
  def index
    @top_coupons = Coupon.showable.find(:all, {:order => 'priority DESC', :limit => 8})
    @latest_coupons = Coupon.showable.find(:all, {:order => 'created_at DESC', :limit => 8})
    @coupon_categories = CouponCategory.find(:all, {:conditions => 'number_of_coupons > 0', :order => 'number_of_coupons DESC', :limit => 8})
    @last_minute_coupons = Coupon.showable.find(:all, {:order => 'valid_to ASC', :limit => 8})
    @gratis_coupons = Coupon.showable.find(:all, {:conditions => {:kind => gratis_kind}, :limit => 8})
    @top_coupon_merchants = CouponMerchant.find(:all, {
      :order  => 'number_of_coupons DESC',
      :limit  => 15
    })
  end
  
  def all_coupon_merchants
    qp = request.query_parameters.symbolize_keys
    if qp_page = qp.delete(:page)
      redirect_to(all_coupon_merchants_url({:page => qp_page}.merge(qp)), {:status => :moved_permanently})
      return
    end
    
    @page_header_tags_configurator.set_all_coupon_merchants
    
    @page = page
    @coupon_merchants_limit = (@frontend_config['COUPONS']['ALL_COUPON_MERCHANTS']['LIMIT']['COUPON_MERCHANTS'] || 20 rescue 20)
    
    coupon_merchants = {}
    
    @first_letters = get_first_letter_of_all
    if @first_letter = params[first_letter_parameter]
      #@coupon_merchants = @coupon_merchants.where(get_first_letter_filter_condition(first_letter))
      coupon_merchants.merge!({:conditions => get_first_letter_filter_condition(@first_letter)})
    else
      @first_letter = I18n.t('shared.all')
    end
    
    #@coupon_merchants = @coupon_merchants.
    #  order('name ASC').
    #  paginate({:page => @page, :per_page => @coupon_merchants_limit})
    @coupon_merchants = CouponMerchant.paginate(coupon_merchants.merge({
      :order => 'name ASC', :page => @page, :per_page => @coupon_merchants_limit})
    )
    
    if @coupon_merchants.empty?
      @page_header_tags['meta']['robots'] = 'noindex, noarchive, follow'
    end

    render :template => 'frontend/coupons/all_coupon_merchants'
  end
  
  def all_merchant_coupons
    unless @coupon_merchant
      redirect_to(all_coupon_merchants_url, {:status => 301})
      return true
    end
    @page = page
    @coupon_category_limit = (@frontend_config['COUPONS']['ALL_MERCHANT_COUPONS']['LIMIT']['COUPONS'] || 20 rescue 20)
    @merchant_coupons = @coupon_merchant.coupons.showable.paginate({
      :page => @page, :per_page => @coupon_category_limit
    })
    @page_header_tags_configurator.set_all_merchant_coupons
    render :template => 'frontend/coupons/all_merchant_coupons'
  end
  
  def search
    now = DateTime.now
    @page = page
    @coupons_limit = 50
    @coupons = Coupon.search(params[:coupon_search_str], {
      :with => {:valid_to => (now..(now + 10.years))},
      :page => @page, :per_page => @coupons_limit
    })
  end
  
  def show
    @coupon_counter = params[:coupon_counter].to_i
    if request.xhr?
      if @coupon = Coupon.find_by_id(params[:id])
        @coupon_merchant = @coupon.coupon_merchant
        render({
          :partial => 'frontend/coupons/show_coupon', 
          :locals => {
            :coupon => @coupon,
            :coupon_counter => @coupon_counter
          }, 
          :layout => false, 
          :content_type => Mime::HTML
        })
      else
        render({
          :partial => 'frontend/coupons/coupon_not_found', 
          :layout => false, 
          :content_type => Mime::HTML
        })
      end
    else
      @coupon = Coupon.find(params[:id])
      @coupon_merchant = @coupon.coupon_merchant
      @page_header_tags_configurator.set_coupon(@coupon, @coupon_merchant)
      render({:template => 'frontend/coupons/show'})
    end
  end
  
  private
  
  def set_coupon_merchant
    @coupon_merchant = CouponMerchant.find_by_merchant_id(params[:merchant_id])
  end
  
  def gratis_kind 
    return Coupon::TYPES.index('gratiscoupons_produktproben')
  end
  
  def get_first_letter_of_all
#    # Rails 3
#    first_letters = nil
#    mc_fl_key = "first_letters_of_all_coupon_merchants"
#    if mc_fl_value = Rails.cache.read(mc_fl_key)
#      if Time.now.ago(1.week) < Time.parse(mc_fl_value[:created_at])
#        first_letters = mc_fl_value[:first_letters]
#      end
#    end
#    unless first_letters
#      first_letters = []
#      first_letters << [I18n.t('shared.all'), CouponMerchant.count]
#      cond_09 = (0..9).map{|number| "name LIKE '#{number}%'"}.join(' OR ')
#      first_letters << ['0-9', CouponMerchant.where(cond_09).count]
#      ('A'..'Z').each do |letter|
#        first_letters << [letter, CouponMerchant.where("name LIKE '#{letter}%'").count]
#      end
#      Rails.cache.write(mc_fl_key, {
#        :first_letters => first_letters, 
#        :created_at    => Time.now.to_s(:db)
#      })

    # Rails 2
    first_letters = []
    first_letters << [first_letters_parameter[:all], CouponMerchant.count]
    cond_09 = (0..9).map{|number| "name LIKE '#{number}%'"}.join(' OR ')
    first_letters << [first_letters_parameter[:'0-9'], CouponMerchant.count({:conditions => cond_09})]
    first_letters_parameter[:'A-Z'].each do |letter|
      first_letters << [letter, CouponMerchant.count({:conditions => "name LIKE '#{letter}%'"})]
    end
    
    return first_letters
  end
  
  def get_first_letter_filter_condition(first_letter)
    a = first_letter.split('-')
    return (a.first..a.last).map{|fl| "name LIKE '#{fl}%'"}.join(' OR ')
  end
  
  def cache_merchant_coupons_path
    merchant_coupons_cache_key
  end
end