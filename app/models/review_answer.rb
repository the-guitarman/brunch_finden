class ReviewAnswer < ActiveRecord::Base
  belongs_to :review_question

  # VALIDATIONS ----------------------------------------------------------------
  validates_presence_of :text, :score, :review_question_id
  validates_uniqueness_of(:text, :scope => :review_question_id,
    :message => " and review question must be unique")
  validates_uniqueness_of(:position, :scope => :review_question_id,
    :message => " and review question must be unique")
  validates_uniqueness_of(:score, :scope => :review_question_id,
    :message => " and review question must be unique")
  validates_numericality_of :score,
    :allow_nil => false,
    :greater_than_or_equal_to => 0,
    :if => Proc.new{|ra| ra.review_question and ra.review_question.answer_type != 'text'}
  validates_numericality_of :score,
    :less_than_or_equal_to => 1,
    :if => Proc.new{|ra| ra.review_question and ra.review_question.answer_type != 'text'}
  validates_inclusion_of :score, :in => [0,1],
    :if => Proc.new{|ra| ra.review_question and ra.review_question.answer_type == 'boolean'}
  validate :check_review_question_answer_type, :check_allow_create, :on => :create
  
  
  before_update :preserve_changes
  before_create :calculate_position
  before_destroy :check_review_question_ratings
  after_destroy :set_followers_positions
  after_update :recalculate_positions
  
  # CALLBACKS METHODS ----------------------------------------------------------
  
  private
  
  def check_review_question_answer_type
    if self.review_question and self.review_question.answer_type == 'text'
      self.errors.add(:base, 
        "review question answer type is 'text' - it doesn't make any sense to add a answer.")
    end
  end
  
  def check_allow_create
    if self.review_question and 
       self.review_question.answer_type == 'boolean' and 
       self.review_question.review_answers.count >= 2
      self.errors.add(:base,
        "review question answer type is 'boolean' - it doesn't make any sense to add another answer.")
    end
  end
  
  def check_review_question_ratings
    if self.review_question.ratings.count > 0
      self.errors.add(:base, "There exists ratings for review question.")
    end
  end
  
  def calculate_position
    if self.review_question
      unless self.position
        self.position = self.review_question.review_answers.count
      else
        max_position = self.review_question.review_answers.count
        if (1..max_position).include?(self.position) == false
          self.position = max_position
        end
      end
    end
  end
  
  def recalculate_positions
    if @changes.include?('position')
      position_old = @changes['position'][0]
      position_new = @changes['position'][1]
      if position_new > position_old
        ReviewAnswer.update_all("position = position-1",
                                 "id <> #{self.id} AND review_question_id = #{self.review_question_id} AND "+
        "position >= #{position_old} AND position <= #{position_new}")
      elsif position_new < position_old
        ReviewAnswer.update_all("position = position+1",
                                 "id <> #{self.id} AND review_question_id = #{self.review_question_id} AND "+
        "position >= #{position_new} AND position <= #{position_old}")
      end
    end
  end
  
  def set_followers_positions(up=false)
    if up then up_down="+" else up_down="-" end
    ReviewAnswer.update_all("position = position "+up_down+" 1",
      "id <> #{self.id} AND review_question_id = #{self.review_question_id} AND "+
      "position >= #{self.position}")
  end
end
