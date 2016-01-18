class AggregatedRating < ActiveRecord::Base
  VALUE_BETWEEN = [0.0,1.0]
  
  belongs_to :review_question
  belongs_to :destination, :polymorphic => true
  
  before_validation :before_validation_on_create_handler, {:on => :create}
  
  validates_presence_of :review_question, :destination
  validates_uniqueness_of :destination_id,
    :scope => [:destination_type, :review_question_id]
  validates_numericality_of :user_count,
    :greater_than => 0,
    :only_integer => true
  validates_numericality_of :value,
    :greater_than_or_equal_to => 0,
    :less_than_or_equal_to    => 1

  def self.find_or_create(review_question, destination)
    ar = nil
    if review_question.answer_type != 'text'
      ar = AggregatedRating.find(:first, {
        :conditions => {
          :review_question_id => review_question.id,
          :destination_id     => destination.id,
          :destination_type   => destination.class.base_class.name
        }
      })
      unless ar
        ar = AggregatedRating.create({
          :review_question_id => review_question.id,
          :destination        => destination
        })
      end
    end
    return ar
  end

  def self.recalculate(review_question, destination)
    if ar = find_or_create(review_question, destination)
      ratings = Rating.find(:all, 
        :joins => :review, 
        :conditions => {
          :review_question_id => review_question.id, 
          :reviews => {
            :destination_id => destination.id, 
            :destination_type => destination.class.base_class.name,
            :state => Review::STATES[:published]
          }
        }
      )
      value = 0
      counter = 0
      ratings.each do |review|
        if review.value
          value += review.value
          counter += 1
        end
      end
      value = counter > 0 ? value / counter : value

      ar.user_count = ratings.count
      ar.value = value
      if ratings.length == 0 
        ar.destroy
      elsif ar.changed?
        ar.save
      end
    end
  end

  private

  def before_validation_on_create_handler
    self.user_count = 0 unless self.user_count?
    self.value = 0 unless self.value?
  end
end