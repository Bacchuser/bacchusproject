class ChangeListTaskItem < ActiveRecord::Migration
  def change
    remove_column :list_task_items, :list_task_id
    add_column :list_task_items, :sort_id, :integer
  end
end
