class AddDetailsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :name, :string
    add_column :users, :age, :integer
    add_column :users, :college, :string
    add_column :users, :knowledges, :string
    add_column :users, :admin, :boolean
    add_column :users, :professor, :boolean
    add_column :users, :course_topics, :text
  end
end
