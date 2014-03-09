class CreateTaskTrees < ActiveRecord::Migration
  def change
    create_table :task_trees do |t|
      t.integer :event_id
      t.integer :tree_level
      t.integer :left_tree
      t.integer :right_tree

      t.timestamps
    end
  end
end
