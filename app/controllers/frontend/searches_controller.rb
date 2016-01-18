class Frontend::SearchesController < Frontend::FrontendController
  include SearchQuery::Logger
  
  # In fact of caching the search form with an authenticity token on any page, 
  # the invalid authenticity token error will happen, if a user will send a 
  # search request from a cached page. So don't raise this error within this 
  # controller.
  skip_before_filter :verify_authenticity_token
  
  before_filter :set_search_string_and_search_mode

  def search
    unless @search.blank?
      if @search == t('shared.search.field_default_value')
        @search = ''
      else
        log_search_query('search', @search)
        @cities = @locations = @coupons = []
        if ThinkingSphinx.sphinx_running?
          begin
            @cities = City.search(@search, {:without => {:number_of_locations => 0}})
            @locations = Location.search(@search, {:with => {:showable => true}})
            @coupons = Coupon.search(@search, {:with => {:showable => true}})
          rescue Riddle::ConnectionError => e
            @search_error = true
          end
        end
      end
    end
  end
  
  private
  
  def set_search_string_and_search_mode
    @search = params[:search].to_s.strip
    # now copy the search string
    @search_internal = String.new(@search)
    @search_options = {
      #:classes       => [],
      :match_mode    => :all,
      #:with          => {:showable => true},
      :ignore_errors => !Rails.env.development?,
      :max_matches   => 50,
      :page          => 1, 
      :per_page      => 50
    }
  end
end
