# FileUtils
# - To create a directory for images
require 'fileutils'
FileUtils.mkdir("#{ARGV[0]}")

# Mechanize
# - To crawl the interwebs
require 'mechanize'
agent = Mechanize.new
agent.user_agent_alias = 'Mac Safari'

# Internet Archive
# - JSLocate script directs to proper server for book images
# - example: http://archive.org/bookreader/BookReaderJSLocate.php?id=warofworlds1898well

page = agent.get "http://archive.org/bookreader/BookReaderJSLocate.php?id=#{ARGV[0]}"

# Book Variables
# - Example 
# - br.bookId = 'warofworlds1898well';
# - br.server = 'ia600409.us.archive.org';
# - br.zip = '/28/items/warofworlds1898well/warofworlds1898well_jp2.zip';
# - br.leafMap = '[1,2,3,4,5,...]';

vars = ['br.bookId', 'br.server', 'br.zip', 'br.leafMap']
book = Hash.new

# @HACK
# - JavaScript variables to Ruby Hash entries
page.body.split(';').select{ |var| 
  var[/^br\./]
}.collect{ |var|
  var.gsub(/\n|\[|\]/,'').split('=').collect{|v| v.strip}
}.select{ |var| 
  vars.include?(var[0])
}.each{|var|
 book[var[0]] = var[1].split(',').size > 1 ? var[1].split(',').map{|s| s.to_i} : var[1].gsub(/'/,'')
}

# @TODO: Use Typhoeus for parallel requests instead
# CURL
# -`curl 'http://ia600309.us.archive.org/BookReader/BookReaderImages.php?zip=/33/items/britishfloramedi01bartuoft/britishfloramedi01bartuoft_jp2.zip&file=britishfloramedi01bartuoft_jp2/britishfloramedi01bartuoft_[0000-0482].jp2&scale=2&rotate=0' -o "british_flora/file_#1.jpg"`
`curl "http://#{book['br.server']}/BookReader/BookReaderImages.php?zip=#{book['br.zip']}&file=#{book['br.bookId']}_jp2/#{book['br.bookId']}_[0000-#{"%04d" % book['br.leafMap'].last}].jp2&scale=2&rotate=0" -o "#{ARGV[0]}/file_#1.jpg"`
