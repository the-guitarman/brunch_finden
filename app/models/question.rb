class Question < ActiveRecord::Base
  belongs_to :rating
  belongs_to :aggregated_rating
  
  validates_presence_of :text
end