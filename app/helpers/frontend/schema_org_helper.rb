module Frontend::SchemaOrgHelper
#  ITEMPROPS = [:name, :itemListElement, :aggregateRating]
  
  def schema_org_body_attributes
    ret = ' itemscope="itemscope" itemtype="http://schema.org/__ITEM_TYPE__"'
    item_type = 'Webpage'
    a_name = action_name
    case controller_name
    when 'cities'
      item_type = 'CollectionPage' if 'show' == a_name
    when 'coupon_categories'
       item_type = 'CollectionPage'
    when 'locations'
      item_type = 'FoodEstablishment' if 'show' == a_name
    #when 'products'
    #  item_type = 'Itempage' if ['show','reviews'].include?(a_name)
    #when 'reviews'
    #  item_type = 'Review' if a_name == 'show'
    when 'states'
      item_type = 'CollectionPage' if 'show' == a_name
    end
    ret.gsub!('__ITEM_TYPE__', item_type)
    return ret.html_safe
  end
  
  def schema_org_attributes(klass)
    attributes = {}
    case klass
    when :product
      attributes = {:itemprop => 'offers', :itemscope => 'itemscope', :itemtype => 'http://schema.org/Product'}
    when :offer
      attributes = {:itemprop => 'offers', :itemscope => 'itemscope', :itemtype => 'http://schema.org/Offer'}
    end
    return attributes
  end
  
  def schema_org_attributes_string(klass)
    attributes = schema_org_attributes(klass)
    ret = ' ' + attributes.map{|key, value| %(#{key}="#{value}") }.join(' ')
    return ret.html_safe
  end
  
#  def schema_org_itemprop(value)
#    ret = ''
#    if ITEMPROPS.include?(value.to_sym)
#      ret = ' itemprop="name"'.html_safe
#    end
#    return ret.html_safe
#  end

  def schema_org_review(&block)
    content = 
      content_tag(:span, @host_full_name, {:itemprop => 'publisher', :class => 'meta-data'}) + 
      yield
    return content_tag(:div, content, {:itemprop => 'review', :itemscope => 'itemscope', :itemtype => 'http://schema.org/Review'})
  end

  def schema_org_review_rating(review, destination, &block)
    content = yield + schema_org_review_rating_meta_tags(review, destination)
    return content_tag(:div, content, {:class => 'review-stars', :itemprop => 'reviewRating', :itemscope => 'itemscope', :itemtype => 'http://schema.org/Rating'})
  end
  
  def schema_org_review_rating_meta_tags(review, destination)
    destination_name = review_destination_name(destination)
    value = review.value? ? Review.decimal_stars(review.value.to_f) : ''
    ret = 
      #content_tag(:span, destination_name, {:itemprop => 'itemReviewed', :class => 'meta-data'}) +
      content_tag(:span, Review::VALUES.max.last, {:itemprop => 'bestRating', :class => 'meta-data'}) +
      content_tag(:span, Review::VALUES.min.last, {:itemprop => 'worstRating', :class => 'meta-data'}) +
      content_tag(:span, value, {:itemprop => 'ratingValue', :class => 'meta-data'})
    return ret.html_safe
  end
  
  def schema_org_aggregated_review(aggregated_review, destination, &block)
    content = yield + schema_org_aggregated_review_meta_tags(aggregated_review, destination)
    return content_tag(:div, content, {:class => 'aggregated-review-stars', :itemprop => 'aggregateRating', :itemscope => 'itemscope', :itemtype => 'http://schema.org/AggregateRating'})
  end
  
  def schema_org_aggregated_review_meta_tags(aggregated_review, destination)
    destination_name = review_destination_name(destination)
    if aggregated_review
      count = aggregated_review.user_count
      value = Review.decimal_stars(aggregated_review.value)
    else
      count = 0
      value = ''
    end
    ret = 
      content_tag(:span, destination_name, {:itemprop => 'itemReviewed', :class => 'meta-data'}) +
      content_tag(:span, count, {:itemprop => 'ratingCount', :class => 'meta-data'}) +
      #content_tag(:span, count, {:itemprop => 'reviewCount', :class => 'meta-data'}) +
      content_tag(:span, Review::VALUES.max.last, {:itemprop => 'bestRating', :class => 'meta-data'}) +
      content_tag(:span, Review::VALUES.min.last, {:itemprop => 'worstRating', :class => 'meta-data'}) +
      content_tag(:span, value, {:itemprop => 'ratingValue', :class => 'meta-data'})
    return ret.html_safe
  end
  
  def schema_org_aggregated_ratings(&block)
    content = yield
    return content_tag(:div, content, {:class => 'aggregated-rating-stars'})
  end
  
  def schema_org_address(&block)
    content = yield
    return content_tag(:div, content, {:itemprop => 'address', :itemscope => 'itemscope', :itemtype => 'http://schema.org/PostalAddress'})
  end
  
  def schema_org_geo(geo_location = nil, options = {}, &block)
    content = yield
    if geo_location
      options[:itemprop]  = 'geo'
      options[:itemscope] = 'itemscope'
      options[:itemtype]  = 'http://schema.org/GeoCoordinates'
      content += (
        content_tag(:span, geo_location.lat, {:itemprop => 'latitude', :class => 'meta-data'}) +
        content_tag(:span, geo_location.lng, {:itemprop => 'longitude', :class => 'meta-data'})
      )
    end
    return content_tag(:div, content, options)
  end
  
  def schema_org_item_list(&block)
    content = yield
    return content_tag(:div, content, {:itemscope => 'itemscope', :itemtype => 'http://schema.org/ItemList'})
  end
  
  def schema_org_photo(&block)
    content = yield
    return content_tag(:div, content, {:itemprop => 'photo', :itemscope => 'itemscope', :itemtype => 'http://schema.org/ImageObject'})
  end
  
  def schema_org_photo_author(frontend_user, options = {})
    options[:itemprop]  = 'author'
    return content_tag(:span, user_name(frontend_user), options)
  end
  
  def schema_org_photo_content_location(location, options = {})
    options[:itemprop]  = 'contentLocation'
    return content_tag(:span, location.name, options)
  end
  
  def schema_org_photo_date_published(location, options = {})
    options[:itemprop]  = 'datePublished'
    options[:content]  = location.created_at.to_date.to_s(:db)
    return content_tag(:span, l(location.created_at), options)
  end
  
  #datePublished" content="2008-01-25"
  
  # lists
  #<div id="search-results-content" itemscope="" itemtype="http://schema.org/ItemList">
  #<meta itemprop="itemListOrder" content="Descending" />
  #<h2 class="blockhead" itemprop="name"><%= headline -%></h2>
  #- sub item: :itemprop => :itemListElement
  
  # review, image
  #<div class="content-block review" id="review" itemprop="review" itemscope="" itemtype="http://schema.org/Review">
  #  <meta itemprop="datePublished" content="<%= review.published_at.iso8601 -%>" />
  #  <meta itemprop="author" content="<%= user_name(review.frontend_user) -%>" />
  #</div>
  #
  #<li class="list-column" itemprop="review" itemscope="" itemtype="http://schema.org/Review">
  #  <h3 itemprop="name"><%= link_to(review_title(review), review_url(review, false)) -%></h3>
  #  <meta itemprop="publisher" content="<%= @host_name -%>" />
  #</li>
  #
  #<div class="review-text" itemprop="reviewBody">...</div>
  
  
  # coupon ???
  #<div itemprop="brand" itemscope itemtype="http://schema.org/Organization">
  #  <meta itemprop="name" content="<%= item.manufacturer.label %>" />
  #</div>
  #<div itemprop="manufacturer" itemscope itemtype="http://schema.org/Organization">
  #  <meta itemprop="name" content="<%= item.manufacturer.label %>" />
  #</div>
  #<div itemprop="offers" itemscope="" itemtype="http://schema.org/AggregateOffer">
  #  <% from_price = "<span class='price'><span>#{t_f_a(:show, :price_from, {:controller => 'frontend/products'})}</span> #{format_product_price(item.min_price)}</span>".html_safe -%>
  #  <% unless action_name.gsub(/_v5$/, '') == 'reviews' -%>
  #    <%= from_price -%>
  #  <% else -%>
  #    <%= link_to(from_price, product_url(item.rewrite)) -%>
  #  <% end -%>
  #  <meta itemprop="lowPrice" content="<%= number_to_currency(item.min_price) -%>" />
  #  <meta itemprop="highPrice" content="<%= number_to_currency(item.max_price) -%>" />
  #  <meta itemprop="offerCount" content="<%= @found_offers_number -%>" />
  #</div>
  #<div id="product-head-description" class="product-head-description supertab" itemprop="description">...</div>
  #
  #<li class="list-column" itemtype="http://schema.org/Offer" itemscope="" itemprop="offers">
  #  <meta content="EUR" itemprop="priceCurrency" />
  #  <div itemprop="itemOffered">
  #      <%= link_to_offer_text_exit(
  #            offer.name, offer,
  #            {:position => offer_counter + 1, :template => template_partial_path},
  #            :itemprop => 'url'
  #          )
  #      -%>
  #  </div>
  #</li>
  #
  #<meta itemprop="productID" content="ean:<%= ean.code -%>"/>
  #<meta itemprop="productID" content="isbn:<%= isbn.code -%>"/>
  #<meta itemprop="productID" content="pzn:<%= pzn.code -%>"/>
  #<meta itemprop="productID" content="mpn:<%= mpn.code -%>"/>
  
end