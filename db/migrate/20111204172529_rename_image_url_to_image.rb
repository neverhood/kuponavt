class RenameImageUrlToImage < ActiveRecord::Migration

  def change
    rename_column :offers, :image_url, :image
  end

end
