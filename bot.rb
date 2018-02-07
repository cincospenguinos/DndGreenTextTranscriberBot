#!/usr/bin/env ruby
require 'redd'
require 'ocr_space'

reddit = Redd.it(
  user_agent: 'Redd:DndGreenTextBot',
  client_id: '61H44wBCl1Vz0Q',
  secret: 'eIKyRMCnM1syAhoozjMU_iMtzm0',
  username: 'DndGreenTextBot',
  password: ENV['DND_GREEN_TEXT_PASS']
)

ocr = OcrSpace::Resource.new(apikey: ENV['OCR_SPACE_API_KEY'])

newest = reddit.subreddit('DnDGreentext').new(limit: 2, time: :hour)

hour_ago = DateTime.now - (1 / 24.0)
newest.each do |post|
  if post.is_self
    print "Hiding #{post.id}..."
    post.hide
    puts 'done.'
  else

    title = post.id
    text = ''
    move_on = false

    post.preview[:images].each do |img|
      url = img[:source][:url]
      begin
        img_text = ocr.clean_convert(url: url)
        img_text.gsub!('>', "\n>")
        text += "#{img_text}\n"
      rescue
        puts "OCR could not handle #{url}"
        move_on = true
      end
    end

    if move_on
      move_on = false
      next
    end

    if text.strip.empty?
      puts "#{post.id} --> #{post.title} is empty! Hiding..."
      post.hide
      next
    end

    text += "\n\n********\n^I ^am ^a ^bot, ^created ^by ^/u/cincospenguinos. ^See ^my ^source ^code " + 
    '^[here](https://github.com/cincospenguinos/DndGreenTextTranscriberBot)!'

    puts 'Posting reply...'
    post.reply(text)
    post.hide
  end
end