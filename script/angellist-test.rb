require 'open-uri'
require 'json'

@slug = "angellist"
data = Hash.new

result = JSON.parse(open("https://api.angel.co/1/startups/search?slug="+ @slug).read)

data["contact_name"] = result["name"]
data["url"] = result["company_url"]
data["twitter_id"] = result["twitter_url"]sub(/[a-zA-Z0-9:\/\.]*twitter.com\//, '')
data["blurb"] = result["product_desc"]
location = result["locations"][0]
data["location"] = location["display_name"]

puts data