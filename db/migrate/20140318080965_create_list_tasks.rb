class CreateListTasks < ActiveRecord::Migration
  def change
    create_table :list_tasks do |t|
      t.integer :task_id

      t.timestamps
    end
  end
end
