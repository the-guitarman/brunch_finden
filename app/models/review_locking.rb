class ReviewLocking < ActiveRecord::Base
  belongs_to :review
  
  validates_presence_of :reason, :review
  validates_inclusion_of :state, :in => Review::STATES.values
  #validates :reason, :review, :presence => true
  #validates :state, :inclusion => {:in => Review::STATES.values}
  
  after_create :after_create_send_email
  
  private
  
  def after_create_send_email
    if self.review.send_email?
      #Frontend::ReviewMailer.review_locked(self.review).deliver
    end
  end
end
