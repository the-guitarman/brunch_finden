class CreateReviewTemplate < ActiveRecord::Migration
  def self.up
    create_table :review_template_questions do |t|
      t.integer  :review_template_id
      t.integer  :review_question_id
      t.integer  :priority
      t.datetime :created_at
      t.datetime :updated_at
      t.boolean  :obligation, :default => false, :null => false
    end

    add_index :review_template_questions, [:review_question_id]
    add_index :review_template_questions, [:review_template_id]

    create_table :review_templates do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :destination_type
    end
  end

  def self.down
    drop_table :review_templates
    drop_table :review_template_questions
  end
end
