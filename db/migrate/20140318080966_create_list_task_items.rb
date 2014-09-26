class CreateListTaskItems < ActiveRecord::Migration
  def change
    create_table :list_task_items do |t|
      t.integer :list_task_id
      t.integer :priority

      t.string :title
      t.string :description

      t.datetime :start_at
      t.datetime :end_at
      t.boolean :is_active
      t.timestamps
    end
  end
end
