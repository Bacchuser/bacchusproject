class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.date :created_at
      t.date :updated_at
      t.string :label
      t.boolean :is_visible

      t.integer :event_id
      t.integer :tree_level
      t.integer :left_tree
      t.integer :right_tree

      t.timestamps
    end
  end
end
