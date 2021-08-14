module LyricsScraper

  def scrape(songs)
    config
    browser = Capybara.current_session
    driver = browser.driver.browser
    songs.each do |song|
      parse_page(song, browser, driver)
    end
  end

  def parse_page(song, browser, driver)
    browser.visit(song.url)
    wait_to_load(driver)
    html = Nokogiri::HTML(HTTParty.get(browser.current_url).body)

    # Check to see if there are any lyrics on the page
    return if(html.css('div.LyricsPlaceholder__Container-uen8er-1').count != 0)
    # Grab all lyrics containers (lyrics divs are separated by ads, etc)
    artist = html.css('.SongHeader__Artist-sc-1b7aqpg-9')[0].text
    title = html.css('.SongHeader__Title-sc-1b7aqpg-7')[0].text

    song.update(artist: artist, title: title)

    lyrics_containers = html.css('div.Lyrics__Container-sc-1ynbvzw-8')
    write_lyrics_to_file(lyrics_containers, song)


    # Unfinished logic to try and parse which lyrics are Jon Mess lyrics
    # 
    # lyrics_containers.each do |container|
    #   # Skip non Jon Mess lyrics
    #   next unless container.text.include?('Jon Mess')
    #   parse_text(container.xpath('text()'), song)
    # end

  end

  # Unfinished method. Attempt to write logic to pull only Jon Mess Lyrics
  def parse_text(text, song)
    i = 0
    while i < text.length
      current = text[i]
      if current.text.include?('Jon Mess')
        i += 1
        loop do
          binding.pry
          current = text[i]
          Line.new(song: song, text: current.text)
          i+= 1
        end 
      end
      i += 1
    end

  end

  def write_lyrics_to_file(containers, song)

    binding.pry
    output = File.new("./lib/lyrics/#{song.title} - #{song.artist}.txt", "a+")
    containers.each do |container|
      text = container.xpath('text() or /i.text()')
      text.each{|line| output.puts(line.text)}
      output.puts("")
    end
    output.close
    binding.pry
  end

  def wait_to_load(driver)
    loop do
      sleep(1)
      break if driver.execute_script('return document.readyState') == "complete"
    end
  end

  def config
    Capybara.register_driver :selenium do |app|  
      Capybara::Selenium::Driver.new(app, browser: :chrome,)
    end
    Capybara.javascript_driver = :chrome
    Capybara.configure do |config|  
      config.default_max_wait_time = 10 # seconds
      config.default_driver = :selenium_chrome
    end
  end

end