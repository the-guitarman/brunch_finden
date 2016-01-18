class Backend::CouponsController < Backend::BackendController
  before_filter :decode_ext_parmeters, :only => [:create, :update]
  
  def show
    coupon = Coupon.find(params[:id])
    render :json => coupon.to_ext_json({:format => :simple})
  end
  
  def list
    select = 'coupons.*, DATEDIFF(valid_to, NOW()) AS remaining_days'
    where  = ["valid_to > ?", DateTime.now]
    joins = nil
    if params[:matched] == 'true'
      joins = 'coupons INNER JOIN coupon_matches ON coupons.id = coupon_matches.coupon_id'
    else
      joins = 'coupons LEFT JOIN coupon_matches ON coupons.id = coupon_matches.coupon_id'
      where[0] += ' AND coupon_matches.coupon_id IS NULL'
    end
    count  = Coupon.count({:joins  => joins, :conditions => where})
#    coupons = filter(sorted(paginated(includes(coupons)))).all
    
    coupons = Coupon.find(:all, {
        :select => select,
        :joins  => joins,
        :conditions => where
    })
    render :json => coupons.to_ext_json({
      :count   => count, 
      :format  => :simple,
      :include => [:coupon_categories]
    })
  end
  
  private
  
  def decode_ext_parmeters
    @ext_params = decode_ext
  end
end
