class AddQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.string  :text
    end
  end

  def self.down
    drop_table :questions
  end
end
