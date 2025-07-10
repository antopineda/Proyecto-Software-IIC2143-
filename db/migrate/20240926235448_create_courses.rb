class CreateCourses < ActiveRecord::Migration[7.0]
  def change
    create_table :courses do |t|
      t.string :title
      t.string :description
      t.float :calification
      t.integer :number_members
      t.integer :price, default: 0, null: false
      t.references :user, null: false, foreign_key: true
      t.text :course_types, array: true
      
      t.timestamps
    end
  end
end
