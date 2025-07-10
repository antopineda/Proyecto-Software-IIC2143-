class AddDefaultValueToAdminInUsers < ActiveRecord::Migration[7.0]
  def change
    change_column_default :users, :admin, from: nil, to: false
    change_column_default :users, :professor, from: nil, to: false
  end
end
