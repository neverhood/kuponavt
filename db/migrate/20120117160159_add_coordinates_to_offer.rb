class AddCoordinatesToOffer < ActiveRecord::Migration
  def change
    add_column :offers, :coordinates, :string
  end
end
