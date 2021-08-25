require 'lyrics_scraper'

namespace :scrape do
  desc "scrapes lyrics"
  task lyrics: :environment do 
    include LyricsScraper
    LyricsScraper.scrape(Song.all)
  end

  desc "Scrapes non RESTful url for all songs"
  task nonRESTful_urls: :environment do
    include LyricsScraper
    LyricsScraper.scrape_nonRESTful_url(Song.where(url: nil))
  end
end
