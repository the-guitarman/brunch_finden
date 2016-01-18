module Mixins::Review
  
  private
  
  def _new_review_variables(destination)
    get_review_template_with_questions(destination)
    
    @review = ::Review.new({:destination => destination})
    @review_questions = _new_ratings(@review, @review_template_questions)
    if logged_in?
      @frontend_user = @review.frontend_user = current_user
    else
      @frontend_user = @review.frontend_user = FrontendUser.new
      @new_frontend_user = FrontendUser.new
      @new_frontend_user_session = FrontendUserSession.new
    end
    @all_valid = false
  end
  
  def _new_ratings(review, review_template_questions, new_ratings = false)
    review_questions = {}
    if defined?(review_template_questions)
      _sort_review_template_questions_by_priority!(review_template_questions)
      review_template_questions.each do |rtq|
        # The answer to a question can be a decimal number (0.0 >= x >= 1.0) or 
        # a text value. This depends on ReviewQuestion#answer_type and it's 
        # importent to know where to save the answer in the rating. 
        parameters = new_ratings ? {} : params.with_indifferent_access
        answer = nil
        unless parameters['review_questions'].blank?
          answer = parameters['review_questions'][rtq.review_question_id.to_s]
        end
        rating_attributes = {:review_question => rtq.review_question, :review => review}
        rating = Rating.new(rating_attributes)
        unless answer.blank?
          rating = Rating.new(rating_attributes)
          if rtq.review_question.answer_type == 'text'
            rating.text = answer
          else
            rating.value = answer
          end
        end
        review_questions[rtq.review_question_id] = rating
      end
    end
    return review_questions    
  end
  
  def _sort_review_template_questions_by_priority!(review_template_questions)
    review_template_questions.sort!{|x,y| x.priority <=> y.priority}
  end
end
