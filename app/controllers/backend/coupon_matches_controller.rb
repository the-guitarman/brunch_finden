class Backend::CouponMatchesController < Backend::BackendController
  def list
    coupon_matches = CouponMatch.where({:coupon_id => params[:coupon_id]})
    coupon_matches.each do |coupon_match|
      coupon_match['name'] = ''
      if dest = coupon_match.destination
        coupon_match['name'] = dest.respond_to?(:full_name) ? dest.full_name : dest.name
      end
    end
    render :json => coupon_matches.to_ext_json({:count  => coupon_matches.count, :format => :simple})
  end
  
  def create
    ActiveSupport::JSON.decode(params[:match_to]).each do |destination|
      CouponMatch.create(destination.merge({:coupon_id => params[:coupon_id]}))
    end
    coupon_matches = CouponMatch.where({:coupon_id => params[:coupon_id]})
    render :json => coupon_matches.to_ext_json({:count => coupon_matches.count, :format => :plain})
  end
  
  def delete
    bulk_deletion(CouponMatch)
  end
end
