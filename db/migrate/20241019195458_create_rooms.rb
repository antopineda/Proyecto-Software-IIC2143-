class CreateRooms < ActiveRecord::Migration[7.0]
  def change
    create_table :rooms do |t|
      t.string :name
      t.boolean :is_private, default: false
      t.references :course, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
