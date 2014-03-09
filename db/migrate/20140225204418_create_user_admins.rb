class CreateUserAdmins < ActiveRecord::Migration
  def change
    create_table :user_admins do |t|
      t.integer :cake_plan_user_id
      t.integer :admin_task_id

      t.timestamps
    end
  end
end
