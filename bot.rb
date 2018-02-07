# bot.rb
require 'redd'
require 'ocr_space'
require 'open-uri'

reddit = Redd.it(
  user_agent: 'Redd:DndGreenTextBot',
  client_id: '61H44wBCl1Vz0Q',
  secret: 'eIKyRMCnM1syAhoozjMU_iMtzm0',
  username: 'DndGreenTextBot',
  password: ENV['DND_GREEN_TEXT_PASS']
)
ocr = OcrSpace::Resource.new(apikey: ENV['OCR_SPACE_API_KEY'])

newest = reddit.subreddit('DnDGreentext').new(limit: 10)

newest.each do |post|
  if post.is_self
    print "Hiding #{post.title}..."
    post.hide
    puts 'done.'
  else
    title = post.id
    post.preview[:images].each do |img|
      url = img[:source][:url]
      text = ocr.clean_convert(url: url)
      text.gsub!('>', "\n>")
      puts text
    end
  end
end
