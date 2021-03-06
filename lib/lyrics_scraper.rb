module LyricsScraper

  def scrape(songs)
    puts "Scraping #{songs.count} songs..."
    count = songs.count
    songs.each_with_index do |song, index|
      print "\rProcessing song ##{index}             "
      puts "\nSong ##{song.id} has no lyrics and has been removed from the database." if parse_page(song) == false
      sleep(0.2)
    end
    puts "\nScraping completed!"
    puts "#{count - Song.count >= 0 ? count - Song.count : 0} songs were removed from the database."
  end

  def scrape_nonRESTful_url(songs)
    puts "Configuring Capybara session"
    config
    browser = Capybara.current_session
    driver = browser.driver.browser
    puts "Parsing #{songs.count} songs..."
    songs.each_with_index do |song, index|
      print "\rGetting URL to Song ##{index + 1}           "
      browser.visit(song.restful_url)
      # wait_to_load(driver)
      song.url = browser.current_url
      song.save
    end
  end

  def parse_page(song)
    html = Nokogiri::HTML(HTTParty.get(song.url).body)

    # Check to see if there are any lyrics on the page
    if(html.css('div.LyricsPlaceholder__Container-uen8er-1').count != 0)
      song.destroy
      return false
    end
    
    begin
      # Grab all lyrics containers (lyrics divs are separated by ads, etc)
      artist = html.search('.SongHeader__Artist-sc-1b7aqpg-9', '.SongHeaderVariantdesktop__Artist-sc-12tszai-9')[0].text
      title = html.search('.SongHeaderVariantdesktop__Title-sc-12tszai-7', '.SongHeader__Title-sc-1b7aqpg-7')[0].text
  
      song.update(artist: artist, title: title)
  
      lyrics_containers = html.css('div.Lyrics__Container-sc-1ynbvzw-8')
      write_lyrics_to_file(lyrics_containers, song)
    rescue => e
      puts e
      binding.pry
    end


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
    filename = "#{song.title} - #{song.artist}.txt".split('/').join(":")
    filepath = "./lib/lyrics/#{filename}"
    # If lyrics already have been logged, do not write lyrics as this would lead to duplicate data
    return if File.exists?(filepath)

    output = File.new(filepath, "a+")
    # Genius separates lyrics into multiple containers of variable length.
    # There is an ad between each container.
    containers.each do |container, index|
      text = container.xpath('text() | descendant::*/text()').reduce(''){|accum, line| accum += line.to_s + "\n"}
      next if IO.binread(output.path).match?(Regexp.quote(text))

      output.puts(text)
      output.puts("") unless index == containers.length - 1
    end
    output.close
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