class ReviewTemplateQuestion < ActiveRecord::Base
  belongs_to :review_template
  belongs_to :review_question

  validates_presence_of :review_template_id, :review_question_id
  validates_inclusion_of :obligation, :in => [true, false]
  validates_uniqueness_of :review_question_id, :scope => :review_template_id
  validates_numericality_of :priority,
    :allow_nil => true,
    :greater_than_or_equal_to => 1
  
  before_create :calculate_priority
  after_update :recalculate_priorities
  after_destroy :set_followers_priorities

  private
  
  def calculate_priority
    unless self.priority
      self.priority = self.review_template.review_template_questions.count + 1
    else
      max_priority = self.review_template.review_template_questions.count + 1
      if (1..max_priority).include?(self.priority) == false
        self.priority = max_priority
      end
    end
  end

  def recalculate_priorities
    changes = self.changes
    if changes.include?('priority')
      priority_old = changes['priority'][0]
      priority_new = changes['priority'][1]
      if priority_new > priority_old
        ReviewTemplateQuestion.update_all("priority = priority-1",
                                 "id <> #{self.id} AND review_template_id = #{self.review_template_id} AND "+
        "priority >= #{priority_old} AND priority <= #{priority_new}")
      elsif priority_new < priority_old
        ReviewTemplateQuestion.update_all("priority = priority+1",
                                 "id <> #{self.id} AND review_template_id = #{self.review_template_id} AND "+
        "priority >= #{priority_new} AND priority <= #{priority_old}")
      end
    end
  end
  
  def set_followers_priorities(up=false)
    if up then up_down="+" else up_down="-" end
    ReviewTemplateQuestion.update_all("priority = priority "+up_down+" 1",
      "id <> #{self.id} AND review_template_id = #{self.review_template_id} AND "+
      "priority >= #{self.priority}")
  end
end
