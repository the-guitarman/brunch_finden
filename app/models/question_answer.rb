class QuestionAnswer < ActiveRecord::Base
  belongs_to :question
  
  validates_presence_of :question_id, :position, :score, :text
end