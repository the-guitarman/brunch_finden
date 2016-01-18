module ReviewTemplateFinder
  # Finds the review template with questions, they belongs to the given 
  # destination (review template questions will be sorted DESC by their 
  # priority).
  # Returns:
  # * @review_template: The found review template (Class: {ReviewTemplate}) or nil.
  # * @review_template_questions: An array of review template questions 
  #   (Class: {ReviewTemplateQuestion}) or an empty array, if there's no 
  #   review template.
  def get_review_template_with_questions(destination)
    @review_template_questions = []
    if destination.respond_to?(:review_template)
      @review_template = destination.review_template
    elsif key = ReviewTemplate::DESTINATION_TYPES.key(destination.class.base_class.name.underscore)
      @review_template = ReviewTemplate.find_by_destination_type(key)
    end
    if @review_template
      @review_template_questions = @review_template.review_template_questions.
        #joins(:review_question).order('analyzable DESC, priority ASC')
        find(:all, {:joins => :review_question, :order => 'analyzable DESC, priority ASC'})
    end
    return @review_template, @review_template_questions
  end
end