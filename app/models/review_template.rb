class ReviewTemplate < ActiveRecord::Base
  DESTINATION_TYPES = {
    0 => 'location'
  }
  
  has_many :review_template_questions, 
    :dependent => :destroy,
    :include => :review_question

  before_validation :before_validation_on_create_handler, {:on => :create}

  validates_presence_of :name
  validates_uniqueness_of :name, :if => :name?
  validates_inclusion_of  :destination_type, :in => DESTINATION_TYPES.keys
  validates_uniqueness_of :destination_type#,
#    :if => Proc.new {|rt| 
#             rt.destination_type? and 
#             rt.destination_type == DESTINATION_TYPES.index('location')
#           }
           
  private

  def before_validation_on_create_handler
    self.destination_type = DESTINATION_TYPES.index('location') unless self.destination_type?
  end
end
