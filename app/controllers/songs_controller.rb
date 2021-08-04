class SongsController < ApplicationController

  def save_urls
    params[:songs].each do |song|
      Song.create(url: "https://genius.com/" + song)
    end
  end

end
