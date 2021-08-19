class ChangeSongsAttributeNames < ActiveRecord::Migration[6.1]
  def change
    rename_column :songs, :url, :restful_url
    add_column :songs, :url, :string
  end
end
