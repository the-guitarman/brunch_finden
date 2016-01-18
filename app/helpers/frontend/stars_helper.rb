module Frontend::StarsHelper
  HOVER_CLS = 'star-hover'
  
  def review_stars(review, destination = nil, options = {})
    destination = review.destination unless destination
    options[:disabled]    = true
    options[:split_stars] = false
    options[:class]       = 'location-star'
    options[:show_raters] = false
    options[:value]       = review ? review.value : nil
    return aggregated_review_stars(destination, options)
  end
  
  def aggregated_review_stars(destination, options = {})
    options[:disabled] = options[:disabled] ? options[:disabled] : true
    options[:show_label] = options[:show_label].nil? ? true : options[:show_label]
    options[:show_raters] = options[:show_raters] ? true : false
    options[:split_stars] = options[:split_stars] ? options[:split_stars] : false
    
    radio_options = {:class => 'location-star'}
    radio_options[:disabled] = options[:disabled]
    radio_options[:class] += " {split:#{options[:split_stars]}}" if options[:split_stars]
    
    if options_value = options[:value]
      review_value = options_value
    elsif ar = destination.aggregated_review
      review_value = ar.value
    else
      review_value = nil
    end
    
    elements = []
    radio_name = "#{destination.class.name.underscore}-#{destination.id}"    
    
    star_values = Review.star_values(!options[:split_stars].blank?)
    star_values.reverse_each do |arr|
      if arr.first > 0
        ra_value = star_values.select{|v| v.first <= review_value.to_f}.sort.last.first
        elements << radio_button_tag(
          radio_name, arr.first, (arr.first == Review.normalized_value(ra_value)), 
          radio_options #.merge({:title => "durchnittliche Bewertung: #{ar_val}"})
        )
      end
    end
    elements.reverse!
    #elements.unshift(label_tag(radio_name, I18n.t('shared.new_review.value')))
    if options[:show_raters]
      raters = '(0)'
      if ar and ar.user_count.to_i > 0
        raters = link_to("(#{ar.user_count.to_i})", location_rewrite_url(create_rewrite_hash(destination.rewrite).merge({:anchor => :reviews})))
      end
      elements << content_tag(:span, raters, {:class => :raters})
    end
    label = ''
    if options[:show_label]
      label = content_tag(:div, I18n.t('shared.new_review.value'), {:class => 'label'})
    end
    form = content_tag(:form, elements)
    return content_tag(:div, label + form, {:class => 'location-stars', :title => review_stars_title(destination.name, review_value, true)}).html_safe
  end
  
  def review_stars_title(name, value, aggregated = false)
    if value
      if aggregated
        human_name = AggregatedReview.human_name({:count => 1})
      else
        human_name = Review.human_name({:count => 1})
      end
      ret = 
        "#{human_name} #{I18n.t('shared.for')} #{name} - " + 
        star_translation(star_with_precision(value), Review::VALUES.max.last)
    else
      ret = I18n.t('shared.stars.no', {:destination_name => name})
    end
    return ret.html_safe
  end
  
  def star_translation(count, total)
    I18n.t('shared.stars.out_of_stars_2', {:count => count, :total => total})
  end
  
  def star_with_precision(value)
    val = Review.decimal_stars(value)
    int = val.to_i
    precision = 1
    if val - int == 0
      val = int
      precision = 0
    end
    return number_with_precision(val, {:precision => precision})
  end
  
  def set_review_stars(review_or_rating, options = {})
    radio_options = {:class => 'set-location-star'}
    elements = []
    radio_name = "#{review_or_rating.class.name.underscore}[value]"
    star_values = Review.star_values #.select{|arr| arr.first > 0}
    star_values.reverse_each do |arr|
      if not options[:required].blank? and star_values.first == arr
        radio_options[:class] += ' required'
      end
      if arr.first == 0.0
        radio_options[:class] += ' dark-star'
      end
      elements << radio_button_tag(
        radio_name, arr.first, false, 
        radio_options.merge({:title => star_translation(arr.last, star_values.length - 1)})
      )
    end
    elements.reverse!
    hover_cls = HOVER_CLS
    unless options[:star_hover].blank?
      elements << content_tag(:span, I18n.t('shared.new_review.please_select'), {:class => hover_cls})
    end
    unless request.xhr?
      content_for(:jquery_on_ready, js_set_destination_stars(hover_cls, options))
    else
      elements << javascript_tag(js_set_destination_stars(hover_cls, options))
    end
    return content_tag(:div, elements, {:class => 'location-stars'})
  end
  
  def js_set_destination_stars(hover_cls = nil, options = {})
    return js_set_stars('set-location-star', hover_cls, options)
  end
  
  
  
  def rating_stars(review_question, rating, options = {})
    options[:disabled]    = true
    options[:split_stars] = false
    options[:class]       = 'location-star'
    options[:show_raters] = false
    options[:value]       = rating ? rating.value : nil
    return aggregated_rating_stars(review_question, rating, options)
  end
  
  def aggregated_rating_stars(review_question, rating, options = {})
    options[:answer_position] = options[:answer_position] ? options[:answer_position] : :before # :before/:after
    options[:disabled] = options[:disabled] ? options[:disabled] : true # true/false
    options[:show_raters] = options[:show_raters] ? true : false # true/false
    options[:split_stars] = options[:split_stars] ? options[:split_stars] : false # false/2
    
    radio_options = {:class => 'location-star'}
    radio_options[:disabled] = options[:disabled]
    radio_options[:class] += " {split:#{options[:split_stars]}}" if options[:split_stars]
    
    if options_value = options[:value]
      rating_value = Rating.normalized_value(options_value, options[:split_stars], true)
    elsif rating
      rating_value = Rating.normalized_value(rating.value, options[:split_stars], true)
    else
      rating_value = nil
    end
    
    elements = []
    radio_name = "#{review_question.class.table_name}[#{review_question.id}]"
    #ra = review_question.review_answers.order('position ASC').map{|ra| [ra.text, ra.score]}
    review_answers = review_question.review_answers.find(:all, {:order => 'position ASC'})
    review_answers.each do |ra|
      if options[:split_stars]
        star_values = Rating.star_values(options[:split_stars], true)
        #ra_index = star_values.map{|v| v.to_s}.index(ra.score.to_s)
        ra_value = star_values.select{|v| v >= ra.score}.sort.first
        ra_index = star_values.map{|v| v.to_s}.index(ra_value.to_s)
        ra_scores = star_values[(ra_index - (options[:split_stars] - 1))..ra_index]
      else
        ra_scores = [ra.score]
      end
      ra_scores.each do |score|
        elements << radio_button_tag(
          radio_name, score, score.to_s == rating_value.to_s, 
          radio_options.merge({:title => ra.text})
        )
      end
    end
    review_question_answer = get_review_question_answer_text(rating, review_question)
    if rating_value.to_f > 0
      #answer = label_tag(radio_name, review_question.text)
      answer = content_tag(:span, review_question_answer, {:class => :answer})
      if options[:answer_position] == :before
        elements.unshift(answer)
      else
        elements << answer
      end
    end
    if options[:show_raters]
      elements << content_tag(:span, "(#{rating.user_count.to_i})", {:class => :raters})
    end
    label = content_tag(:div, review_question.text, {:class => 'label'})
    form = content_tag(:form, elements)
    ret = content_tag(:div, label + form, {:class => 'location-stars', :title => review_question_answer}).html_safe
    return ret
  end
  
  def set_review_question_stars(review_template_question, value, options = {})
    container_cls = 'location-stars'
    review_question = review_template_question.review_question
    radio_options = {:class => 'set-review-question-star'}
    elements = []
    radio_name = "#{review_question.class.table_name}[#{review_question.id}]"
    #ra = review_question.review_answers.order('position ASC').map{|ra| [ra.text, ra.score]}
    review_answers = review_question.review_answers.find(:all, {:order => 'position ASC'})
    review_answers.each do |ra|
      if review_template_question.obligation and review_answers.first == ra
        radio_options[:class] += ' required'
      end
      elements << radio_button_tag(
        radio_name, ra.score, value, 
        radio_options.merge({:title => ra.text})
      )
    end
    hover_cls = HOVER_CLS
    unless options[:star_hover].blank?
      elements << content_tag(:span, I18n.t('shared.new_review.please_select'), {:class => hover_cls})
    end
    unless request.xhr?
      content_for(:jquery_on_ready, js_set_review_question_stars(hover_cls, options))
    else
      elements << javascript_tag(js_set_review_question_stars(hover_cls, options))
    end
    return content_tag(:div, elements, {:class => container_cls})
  end
  
  def js_set_review_question_stars(hover_cls = nil, options = {})
    return js_set_stars('set-review-question-star', hover_cls, options)
  end
  
  def js_set_stars(input_cls, hover_cls = nil, options = {})
    js_hover = ''
    js_init  = ''
    unless options[:star_hover].blank?
      js_hover = js_hover_and_select_events(hover_cls)
      js_init  = js_init_star_hover(hover_cls)
    end
    return "
      $('input.#{input_cls}').rating({
        #{js_hover}
      });
      #{js_init}"
  end
  
  def js_init_star_hover(cls = 'star-hover')
    return "
      var sh = $('.location-stars .#{cls}');
      if (sh.length > 0) {
          $.each(sh, function(idx, el){
              var element = $(el);
              var checkbox = element.siblings('input[type=radio][checked=checked]');
              if (checkbox.length > 0) {
                  element.html(checkbox.attr('title'));
              }
          });
      };"
  end
  
  def js_hover_and_select_events(cls = 'star-hover')
    return "
      focus: function(value, link){
          var tip = $(link).parents('.location-stars').find('.#{cls}');
          tip[0].data = tip[0].data || tip.html();
          tip.html(link.title || 'value: '+value);
      },
      blur: function(value, link){
          var tip = $(link).parents('.location-stars').find('.#{cls}');
          $(link).parents('.location-stars').find('.#{cls}').html(tip[0].data || '');
      },
      callback: function(value, link){
          $(link).parents('.form-entry').removeClass('error');
          var tip = $(link).parents('.location-stars').find('.#{cls}');
          tip[0].data = link.title;
          tip.html(link.title);
      }"
  end
  
  def set_review_question_select(review_template_question, value)
    review_question = review_template_question.review_question
    # prepare select tag options
    select_tag_options_array = [[I18n.t('shared.new_review.please_select'), '']]
    #select_tag_options_array += rq.review_answers.order('position ASC').map{|ra| [ra.text, ra.score]}
    select_tag_options_array += review_question.review_answers.find(:all, {
      :order => 'position ASC'
    }).map{|ra| [ra.text, ra.score]}
    select_tag_options = options_for_select(select_tag_options_array, value)
    return select_tag("review_questions[#{review_question.id}]", select_tag_options, {:class => ''})
  end
end