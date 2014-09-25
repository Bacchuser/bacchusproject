class ChangeEvent < ActiveRecord::Migration
  def change
    add_column :events, :label, :string
    add_column :events, :city, :string
    add_column :events, :street, :string
    add_column :events, :country, :string
    add_column :events, :latitude, :float
    add_column :events, :longitude, :float
  end
end
