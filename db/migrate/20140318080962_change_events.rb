class ChangeEvents < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.integer :localisation_id
    end
  end
end
