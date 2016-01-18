#Describes an reply of an FrontendUser to a ReviewQuestion with an spezified
#ReviewAnswer.
class Rating < ActiveRecord::Base
  include Mixins::RatingCompleteness
  
  VALUE_BETWEEN = [0.0,1.0]
  POSITIVE_RATINGS_GT_OR_EQ = 0.6
  
  belongs_to :review_question
  belongs_to :review

  validates_presence_of :review_question, :review
  validates_presence_of :value, 
    :if => Proc.new{|r| (not r.review_question.blank?) and
      ['list', 'boolean'].include?(r.review_question.answer_type) and r.obligated? }
  validates_numericality_of :value,
    :greater_than_or_equal_to => VALUE_BETWEEN.first, 
    :less_than_or_equal_to    => VALUE_BETWEEN.last,
    :if => :value?
  validates_presence_of :text, 
    :if => Proc.new{|r| (not r.review_question.blank?) and
      r.review_question.answer_type == 'text' and r.obligated?}

  before_save :check_obligation
  after_save :calculate_aggregations
  after_destroy :calculate_aggregations

  def destination
    review.destination if review
  end

  def frontend_user
    review.frontend_user if review
  end

  def calculate_aggregations
    unless self.review_question.answer_type == 'text'
      AggregatedRating.recalculate(self.review_question, self.destination)
    end
  end

  def obligated?
    ret = false
    if dest = destination and rt = dest.review_template
      if Rails.version >= '3.0.0'
        rtq = ReviewTemplateQuestion.where({
          :review_template_id => rt.id,
          :review_question_id => self.review_question_id
        }).first
      else
        rtq = ReviewTemplateQuestion.find(:first, {
          :conditions => {
            :review_template_id => rt.id,
            :review_question_id => self.review_question_id
          }
        })
      end
      ret = rtq.obligation if rtq
    end
    return ret
  end

  def facultative?
    not obligated?
  end

  def optional?
    facultative?
  end
  
  def self.normalized_value(value, split_stars = false, zero_star = false)
    ret = 0.0
    sv = star_values(split_stars, zero_star)
    if val = sv.find{|el| el >= value}
      ret = val
    end
    return ret
  end
  
  def self.star_values(split_stars = false, zero_star = false)
    values = []
    values << Rating::VALUE_BETWEEN.first if zero_star
    count = 5 * (split_stars ? split_stars : 1)
    step = Rating::VALUE_BETWEEN.last / count
    count.times do |n|
      values << step * (n + 1)
    end
    return values
  end
  
  private
  
  def check_obligation
    ret = true
    if self.facultative?
      if (not self.review_question.blank?) and
         ['list', 'boolean'].include?(self.review_question.answer_type) and 
         self.value.blank?
        ret = false
      elsif (not self.review_question.blank?) and
         self.review_question.answer_type == 'text' and 
         self.text.blank?
        ret = false
      end
    end
    return ret
  end
end
