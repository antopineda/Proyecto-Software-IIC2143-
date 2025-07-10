class CreateEnrollmentRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :enrollment_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end
