class CreateJoinTableHistories < ActiveRecord::Migration[7.0]
  def change
    create_join_table :courses, :users, table_name: :histories do |t|
    end
  end
end
