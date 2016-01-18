class CreateReviewQuestionsAndReviewAmswers < ActiveRecord::Migration
  def self.up
    create_table :review_questions do |t|
      t.string   :text
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :answer_type, :default => :list, :null => false
      t.boolean  :analyzable,  :default => false,  :null => false
    end
    
    create_table :review_answers do |t|
      t.integer  :review_question_id
      t.string   :text
      t.integer  :position
      t.decimal  :score, :precision => 3, :scale => 2, :default => 0.0
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :review_answers, [:review_question_id]
  end

  def self.down
    drop_table :review_answers
    drop_table :review_questions
  end
end
