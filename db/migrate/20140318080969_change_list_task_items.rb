class ChangeListTaskItems < ActiveRecord::Migration
  def change
    add_column :list_task_items, :task_id, :integer
  end
end
