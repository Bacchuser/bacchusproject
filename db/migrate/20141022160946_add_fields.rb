class AddFields < ActiveRecord::Migration
  def change
    add_column :list_tasks, :description, :text
  end
end
