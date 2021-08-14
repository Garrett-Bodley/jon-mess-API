require 'lyrics_scraper'

namespace :scrape do
  desc "scrapes lyrics"
  task lyrics: :environment do 
    include LyricsScraper
    LyricsScraper.scrape(Song.all)
  end
end
