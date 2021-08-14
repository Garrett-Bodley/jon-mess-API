class AddTitleAndArtistToSongs < ActiveRecord::Migration[6.1]
  def change
    add_column :songs, :title, :string
    add_column :songs, :artist, :string
  end
end
