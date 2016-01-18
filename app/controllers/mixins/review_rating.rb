module Mixins::ReviewRating
  
  private
  
  # @api private
  # Returns the review and its destination for a given review id.
  # 
  # == Parameters
  # * id or review_id: The review id number.
  # 
  # == Variables
  # * @review: The review object (Class: {Review}).
  # * @destination: It's an object of these 
  #   classes: {Product}, {Shop}, {ManufacturerCompany}.
  def set_review_variable
    if review_id = (params[:id] || params[:review_id])
      @review = Review.showable.where({:id => review_id}).first
    elsif review_rewrite = params[:rewrite]
      @review = Review.showable.where({:rewrite => review_rewrite}).first
    end
    @destination = @review.destination if @review
    if @destination.blank?
      # No category given, so raise an error, which will be processed in the
      # application controller (url forwarding).
      raise(ActiveRecord::RecordNotFound, 'Review destination object not found!')
    end
  end
  
  def on_the_fly_check
    @field_id    = params[:field_id]
    @field_name  = params[:field_name]
    @field_value = params[:field_value]
    @frontend_user = nil
    unless @field_name.blank?
      if @field_name == 'frontend_user[email]'
        unless @frontend_user = FrontendUser.find_by_email(@field_value)
          @frontend_user = FrontendUser.new({:email => @field_value})
          @frontend_user.valid?
        end
      end
    end
  end
end
