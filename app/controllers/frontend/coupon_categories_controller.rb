class Frontend::CouponCategoriesController < Frontend::FrontendController
  caches_page :index
  
  before_filter :set_coupon_category, :only => :show
#  caches_page :show,
#    :cache_path => proc{|c| 
#      parameters = (c.params || {}).copy
#      parameters.delete(:utf8)
#      coupon_category = c.instance_variable_get(:@coupon_category)
#      parameters.merge!({:date => coupon_category.updated_at.to_i})
#      return parameters
#    }
  caches_page :show, :cache_path => :cache_coupon_category_path.to_proc
  
  def index
    @coupon_categories = CouponCategory.find(:all, 
      :conditions => ['number_of_coupons > ?', 0],
      :order => 'name ASC'
    )
  end
  
  def show
    unless @coupon_category
      redirect_to(coupon_categories_url, {:status => 301})
      return true
    end
    @page = page
    @coupon_category_limit = (@frontend_config['COUPON_CATEGORIES']['SHOW']['LIMIT']['COUPONS'] || 20 rescue 20)
    @coupons = @coupon_category.coupons.showable.paginate({
      :order => 'valid_to ASC', :page => @page, :per_page => @coupon_category_limit
    })
    @page_header_tags_configurator.set_coupon_category
  end
  
  private
  
  def set_coupon_category
    @coupon_category = CouponCategory.find_by_rewrite(params[:rewrite])
  end
  
  def active_record_not_found_handler(exception)
    if request.path.match(/\/gutschein-kategorien\/\d+?\.html/)
      redirect_to coupon_categories_path, :status => 301
    else
      super
    end
  end
  
  def cache_coupon_category_path
    coupon_category_cache_key(@coupon_category, params)
  end
end