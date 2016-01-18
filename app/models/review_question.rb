class ReviewQuestion < ActiveRecord::Base
  has_many :ratings, :dependent => :destroy
  has_many :aggregated_ratings, :dependent => :destroy
  has_many :review_template_questions, :dependent => :destroy
  has_many :review_templates, :through => :review_template_questions
  has_many :review_answers, :dependent => :destroy

  ANSWER_TYPES = ['list', 'boolean', 'text']

  # VALIDATIONS ----------------------------------------------------------------
  validates_presence_of :text
  validates_inclusion_of :answer_type, :in => ANSWER_TYPES
  validate :check_answer_type, :on => :update

  
  after_validation :set_analyzable

  
  private 
  
  def check_answer_type
    return true unless self.changes.include?('answer_type')
    if self.answer_type == 'boolean' and self.changes['answer_type'][0] == 'list'
      if self.review_answers.count > 2
        self.errors.add(:answer_type, "there are more than 2 answers - it doesn't make any sense")
        return false;        
      end
    end
    true
  end
  
  def set_analyzable
    if self.answer_type? and self.answer_type != 'list'
      self.analyzable = false
    end
  end
end
