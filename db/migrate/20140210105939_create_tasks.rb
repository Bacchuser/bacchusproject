class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.date :created_at
      t.date :updated_at
      t.string :label
      t.boolean :is_visible

      t.timestamps
    end
  end
end
