class CreateBotStatistics < ActiveRecord::Migration
  def change
    create_table :bot_statistics do |t|
      t.integer :offer_id
      t.integer :category_id
      t.string :match
      t.string :found_in

      t.timestamps
    end
  end
end
