class CreateLessons < ActiveRecord::Migration[7.0]
  def change
    create_table :lessons do |t|
      t.string :title
      t.text :content
      t.integer :number_of_questions_in_quiz, null: false
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end
  end
end
