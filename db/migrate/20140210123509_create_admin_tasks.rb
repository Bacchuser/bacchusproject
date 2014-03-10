class CreateAdminTasks < ActiveRecord::Migration
  def change
    create_table :admin_tasks do |t|
      t.integer :task_id
      t.datetime :start_at
      t.datetime :end_at
      t.string :description
      t.boolean :is_public
      t.timestamps
    end
  end
end
