class CreateLocalisations < ActiveRecord::Migration
  def change
    create_table :localisations do |t|
      t.float :latitude
      t.float :longitude
      t.string :town
      t.integer :zip
      t.string :street
      t.string :country
      t.string :comments
      t.timestamps
    end
  end
end
