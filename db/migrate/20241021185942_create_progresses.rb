class CreateProgresses < ActiveRecord::Migration[7.0]
  def change
    create_table :progresses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :lesson, null: false, foreign_key: true
      t.references :quiz, null: false, foreign_key: true
      t.boolean :completed_lesson
      t.boolean :completed_quiz

      t.timestamps
    end
  end
end
