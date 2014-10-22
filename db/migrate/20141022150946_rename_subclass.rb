class RenameSubclass < ActiveRecord::Migration
  def change
    rename_column :tasks, :subclass_name, :subtask_name
    rename_column :tasks, :subclass_id, :subtask_id
  end
end
