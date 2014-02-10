class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :access_control
      t.date :created_at
      t.date :updated_at
      t.timestamps
    end
  end
end
