#encoding: UTF-8

# @api public
#
# == Description
# Controller to create, check and confirm reviews.
class Frontend::ReviewsController < Frontend::FrontendController
  include Mixins::ReviewRating
  include Mixins::Review
  
  before_filter :require_user, :only => [:edit, :update, :destroy]
  
  ajax_actions = [:check,:check_completeness_for_new,:check_completeness_for_existing]
  
  before_filter :set_review_variable, :except => [:new,:create,:confirm] + ajax_actions
  before_filter :set_new_review_destination_variable, :only => [:new,:create,:check_completeness_for_new]
#  before_filter :get_review_value_translations, :only => [:new,:create,:edit,:update]
#  before_filter :set_review_header_variables, :except => [:confirm]
  
  before_filter :update_requires_review_owner, :only => [:edit, :update]
  before_filter :destruction_requires_review_owner, :only => [:destroy]
  
  before_filter :set_review_page_header_tags, :except => [:new,:create,:confirm] + ajax_actions
#  before_filter :set_review_destination_page_header_tags, :only => [:new,:create]
  skip_before_filter :set_page_header_tags, :only => ajax_actions
  
  def new
    _new_review_variables(@destination)
    unless request.xhr?
      render({:template => 'frontend/reviews/new'})
    else
      render({
        :partial => 'frontend/reviews/new', 
        :layout => false, 
        :content_type => Mime::HTML
      })
    end
  end
  
  def create
    get_review_template_with_questions(@destination)
    
    @objects_to_validate = []
    
    autologin_the_user
    
    # frontend user
    @frontend_user = find_or_initialize_frontend_user
    @objects_to_validate << @frontend_user if @frontend_user.new_record?

    unless logged_in?
      @new_frontend_user = @frontend_user
      @new_frontend_user_session = FrontendUserSession.new
    end
    
    # review
    @review = Review.new(params[:review].merge({
       :destination   => @destination, 
       :frontend_user => @frontend_user
    }))
    @objects_to_validate << @review
    if logged_in?
      @review.general_terms_and_conditions = true
    elsif params[:review]
      @review.general_terms_and_conditions = params[:review][:general_terms_and_conditions]
    end
    
    # ratings
    @review_questions = _new_ratings(@review, @review_template_questions)
    @objects_to_validate += @review_questions.values
    
    # validation check
    @all_valid = validate_objects(*@objects_to_validate)
    
    unless @all_valid
      # show new review template with errors and/or preview
      unless request.xhr?
        render({:template => 'frontend/reviews/new'})
      else
        render({:template => 'frontend/reviews/create.js.rjs'})
      end
    else
      new_frontend_user = @frontend_user.new_record?
      @frontend_user.save
      @review.frontend_user = @frontend_user
      @review.save
      @review_questions.each_value{|r| r.save}
      unless logged_in?
        if Rails.version >= '3.0.0'
          Mailers::Frontend::ReviewMailer.confirmation_code(@review).deliver
        else
          Mailers::Frontend::ReviewMailer.deliver_confirmation_code(@review)
        end
      else
        @review.publish!
        
      end
      unless request.xhr?
        if logged_in?
          redirect_to(location_rewrite_url(create_rewrite_hash(@destination.rewrite)))
        else
          render({:template => 'frontend/reviews/create'})
        end
      else
        @review_questions = _new_ratings(@review, @review_template_questions, true)
        render({:template => 'frontend/reviews/create.js.rjs'})
      end
    end
  end
  
  def destroy
    store_last_location
    if @review.is_comment?
      @review.destroy 
    end
    if @review.frozen?
      # see Mixins::ItemReviewVariables for more information about
      # set_review_sidebar_variables
      set_review_sidebar_variables(@destination)
      set_found_items(@destination)
      
      render(:template => 'frontend/reviews/destroy')
    else
      redirect_back_or_default review_url(@review)
    end
  end
  
  # @api public
  #
  # == Description
  # Checks the received field data and returns JavaScript.
  #
  # == Template
  # Renders: 'frontend/reviews/check.js.rjs'
  # 
  # == Parameters
  # * id or review_id: The review id.
  # 
  # * field_id   : Dom id of the field.
  # * field_name : The field name.
  # * field_value: The field value.
  # 
  # == Variables
  # * @frontend_user: A frontend user object (Class: {FrontendUser}), if 
  #   field_name parameter is 'frontend_user[email]' and the email (parameter
  #   field_value) found. Otherwise nil.
  # 
  # == URLs
  # * URL/Path
  #   * check_reviews_url(99): returns the full url for this
  #     action: ht tp:/ /<host>/reviews/99/check
  #   * check_reviews_path(99): returns the path for this
  #     action: /reviews/99/check
  def check
    on_the_fly_check
    render({:template => 'frontend/reviews/check.js.rjs'})
  end
  
  # @api public
  #
  # == Description
  # An action called via ajax. 
  # Checks the completeness of a review formular. Returns JavaScript.
  #
  # == Template
  # Renders: 'frontend/reviews/check_completeness.js.rjs'
  # 
  # == Parameters
  # * review: A hash with review values (title, text, summary, ...).
  # * review_questions: A hash of rating values. The keys are ids of 
  #   review questions (Class: {ReviewQuestion}) and the values are 
  #   float or text ratings for {Ratings}.
  # 
  # == Variables
  # * @review: A new review object (Class: {Review#new Review#new}).
  # * @destination: The destination of the review. One of {Product, Shop, ManufacturerCompany}.
  # * @review_template: A review template (Class: {ReviewTemplate}).
  # * @review_template_questions: An array of review template questions {ReviewTemplateQuestion}.
  # * @review_questions: A hash: {
  #     review question id 1 => a new rating object,
  #     review question id 2 => a new rating object,
  #     review question id 3 => a new rating object,
  #     review question id 4 => a new rating object,
  #     review question id 5 => a new rating object
  #   }
  # * @review_completeness_notes: A hash with 
  #   review-field-name => completeness-notes: {
  #     :value => ['The rating is required.'],
  #     :text  => ['Please enter your opinion.', 'Please write at least 50 words.']
  #   }
  # * @review_questions_completeness_notes: A hash with 
  #   review-question-field-id => completeness-note: {
  #     review_questions_50 => 'The rating is required.',
  #     review_questions_52 => 'The rating is required.'
  #   }
  # 
  # == URLs
  # * URL/Path
  #   * check_completeness_for_new_review_url(destination): returns the full url for this
  #     action: ht tp:/ /<host>/products/sony-playstation-2/reviews/check-comleteness
  def check_completeness_for_new
    @review = Review.new(params[:review])
    @review.destination = @destination
    check_completeness
  end
  
  def check_completeness_for_existing
    @review = Review.find(params[:id])
    params[:review][:is_comment] = false unless @review.is_comment?
    @review.attributes = params[:review]
    check_completeness
  end
  
  # @api public
  #
  # == Description
  # Confirms and puplishes unpublished reviews. 
  #
  # == Template
  # Renders: 'frontend/reviews/confirm.html.erb'
  # 
  # == Parameters
  # * id: The review id number.
  # * token: the confirmation code of the review.
  # 
  # == Variables
  # * @review: The review (Class: {Review}), if found. Otherwise nil.
  # 
  # == URLs
  # * URL/Path
  #   * confirm_review_url({:id => 999, :token => 'kjfhsdi7f74f'}): returns the full url for 
  #     this action (ht tp:/ /<host>/reviews/999/confirm/kjfhsdi7f74f)
  def confirm
    #@review = Review.unpublished.where({:id => params[:id], :confirmation_code => params[:token]}).first
    @review = Review.find(:first, {
      :conditions => {
        :id => params[:id], 
        :confirmation_code => params[:token],
        :state => Review::STATES[:unpublished]
      }
    })
    if @review
      @review.publish!
    else
      #@review = Review.where({:id => params[:id], :state => Review::STATES[:published]}).first
      @review = Review.find(:first, {
        :conditions => {
          :id => params[:id], 
          :state => Review::STATES[:published]
        }
      })
    end
  end
  
  private
  
  def check_completeness
    get_review_template_with_questions(@review.destination)
    @review_completeness_notes = @review.completeness_notes
    @review_questions_completeness_notes = ratings_notes(set_new_ratings)
    render({:template => 'frontend/reviews/check_completeness.js.rjs'})
  end
  
  # @api private
  # Returns the destination object for a new review.
  # 
  # == Parameters
  # * destination_type: This parameter is set within the application routes (config/routes.rb).
  # 
  # == Variables
  # * @destination: The destination object. It's an object of 
  #   this classes: {Product}, {Shop}, {ManufacturerCompany}.
  #
  def set_new_review_destination_variable
    rewrite = "#{params[:state]}/#{params[:city]}/#{params[:location]}"
    @destination = Location.find_by_rewrite(rewrite)
  end
  
  # @api public
  # Defines @review_questions and returns it as a hash of 
  # review_question_id => {Rating#new Rating#new} pairs for the given review (@review) 
  # and the review template questions array (@review_template_questions).
  # * If @review_template_questions defined and not empty only:
  #   * @review_questions: A hash: {
  #       review question id 1 => {Rating#new Rating#new}[,
  #       review question id 2 => {Rating#new Rating#new}]
  #     }
  # * Otherwise it returns an empty hash.
  def set_new_ratings
    @review_questions = {}
    if defined?(@review_template_questions)
      sort_review_template_questions_by_priority!
      @review_template_questions.each do |rtq|
        # The answer to a question can be a decimal number (0.0 >= x >= 1.0) or 
        # a text value. This depends on ReviewQuestion#answer_type and it's 
        # importent to know where to save the answer in the rating. 
        parameters = params.with_indifferent_access
        answer = nil
        unless parameters['review_questions'].blank?
          answer = parameters['review_questions'][rtq.review_question_id.to_s]
        end
        rating_attributes = {:review_question => rtq.review_question, :review => @review}
        rating = Rating.new(rating_attributes)
        unless answer.blank?
          rating = Rating.new(rating_attributes)
          if rtq.review_question.answer_type == 'text'
            rating.text = answer
          else
            rating.value = answer
          end
        end
        @review_questions[rtq.review_question_id] = rating
      end
    end
    return @review_questions
  end
  
  # @api public
  # Defines @review_questions and returns it as a hash of 
  # review_question_id => {Rating} pairs for the given review (@review) 
  # and the review template questions array (@review_template_questions).
  # * If @review_template_questions defined and not empty only:
  #   * @review_questions: A hash: {
  #       review question id 1 => {Rating}[,
  #       review question id 2 => {Rating}]
  #     }
  # * Otherwise it returns an empty hash.
  def get_ratings
    @review_questions = {}
    if defined?(@review_template_questions)
      sort_review_template_questions_by_priority!
      @review_template_questions.each do |rtq|
        rating = @review.ratings.where({:review_question_id => rtq.review_question_id}).first
        unless rating
          rating = Rating.new({:review_question => rtq.review_question, :review => @review})
        end
        @review_questions[rtq.review_question_id] = rating
      end
    end
    return @review_questions
  end
  
  def sort_review_template_questions_by_priority!
    @review_template_questions.sort!{|x,y| x.priority <=> y.priority}
  end
  
  # Returns a hash of 'review_questions_#{id}' => 'completeness-note' pairs.
  def ratings_notes(ratings = {})
    ret = {}
    ratings.each do |review_question_id, rating|
      if note = rating.completeness_note
        field = "review_questions_#{rating.review_question_id}"
        if rating.review_question.answer_type == 'boolean'
          field = "#{field}_#{Rating::VALUE_BETWEEN.first}"
        end
        ret[field] = note
      end
    end
    return ret
  end
  
  # Returns true, if all given objects are valid. Otherwise false.
  def validate_objects(*objects)
    ret = true
    objects.each do |object|
      unless object.is_a?(Array)
        ret = false unless object.valid?
      else
        ret = false unless object.collect{|o| o.valid?}.all?
      end
    end
    return ret
  end
end