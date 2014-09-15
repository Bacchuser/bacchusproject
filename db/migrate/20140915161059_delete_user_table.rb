class DeleteUserTable < ActiveRecord::Migration
  def change
    remove_column :cake_plan_users, :user_id
    drop_table :users
  end
end
