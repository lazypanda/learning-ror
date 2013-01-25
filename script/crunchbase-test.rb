require 'open-uri'
require 'json'

@permalink = "facebook"
data = Hash.new

result = JSON.parse(open("http://api.crunchbase.com/v/1/company/" + @permalink + ".js?api_key=mz8b94w5wrf3z87ew5z7749z").read)
data["contact_name"] = result["name"]
data["phone"] = result["phone"]
data["url"] = result["homepage_url"]
data["founded_year"] = result["founded_year"]

funding_string = result["total_money_raised"].sub("$","")
funding_multiplier = {
  "B" => 1000000000, "b" => 1000000000,
  "M" => 1000000, "m" => 1000000,
  "K" => 1000, "k" => 1000
}
funding_multiplier.default = 1
multiplier = funding_multiplier[funding_string[-1]]
funding_string = funding_string[0...-1]
funding = Float(funding_string) * multiplier
data["funding_raised"] = funding



data["num_employees"] = result["number_of_employees"]
data["blurb"] = result["overview"]
data["crunchbase_id"] = result["permalink"]
data["twitter_id"] = result["twitter_username"]

location = result["offices"][0]
data["location"] = location["city"] + "," + location["state_code"]

products = result["products"]
projects = ""
products.each do |product|
	product_page = JSON.parse(open("http://api.crunchbase.com/v/1/product/" + product["permalink"] + ".js?api_key=mz8b94w5wrf3z87ew5z7749z").read)
	project = "<p> <h1>" + product["name"] + "</h1>" +
	  "<p>" + product_page["overview"] + "</p> </p>"
	projects += project
end
data["projects_summary"] = projects

investors = Array.new
funding_type = {"angel" => 100, "seed" => 100, 
  "a" => 200, "b" => 300, "c" => 400, "d" => 500
}
funding_type.default = 0
funding_status = 0
if result["ipo"]
	funding_status = 700
end

funding_rounds = result["funding_rounds"]
recent_rounds = funding_rounds.last(3)
funding_rounds.each do |funding_round|
	if funding_status < funding_type[funding_round["round_code"]]
		funding_status = funding_type[funding_round["round_code"]]
	end
	if recent_rounds.include? funding_round
		puts funding_round
		investments = funding_round["investments"]
		investments.each do |investment|
			if investment["company"]
				investors << investment["company"]["name"]
			elsif investment["financial_org"]
				investors << investment["financial_org"]["name"]
			elsif investment["person"]
				investors << investment["person"]["first_name"] + " " + investment["person"]["last_name"]
			end
		end
	end
end
if funding_status == 0
  funding_status = 999
end
data["funding_status"] = funding_status
investors = (investors.uniq.sort_by { |h| h }.reverse!).join(", ")

puts data["funding_raised"]
puts data["funding_status"]