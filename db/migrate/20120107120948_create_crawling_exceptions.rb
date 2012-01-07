class CreateCrawlingExceptions < ActiveRecord::Migration
  def change
    create_table :crawling_exceptions do |t|
      t.text :stacktrace
      t.integer :provider_id
      t.string :error_text
      t.text :offer_attributes
      t.string :offer_url

      t.timestamps
    end
  end
end
