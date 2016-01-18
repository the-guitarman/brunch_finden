class CreateQuestionAnswers < ActiveRecord::Migration
  def self.up
    create_table :question_answers do |t|
      t.integer :question_id
      t.integer :position
      t.decimal :score, :precision => 3, :scale => 2, :default => 0.0
      t.string  :text
    end
  end

  def self.down
    drop_table :question_answers
  end
end
