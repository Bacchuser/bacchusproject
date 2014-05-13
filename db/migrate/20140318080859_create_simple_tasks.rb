class CreateSimpleTasks < ActiveRecord::Migration
  def change
    create_table :simple_tasks do |t|
      t.integer :task_id
      t.datetime :start_at
      t.boolean :is_active
      t.datetime :end_at
      t.datetime :alert_at
      t.timestamps
    end
  end
end
