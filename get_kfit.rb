require 'csv'
require 'pry'
require 'net/http'
require 'nokogiri'
require 'benchmark'
uri = 'https://access.kfit.com/schedules/614474'
partner = 'https://access.kfit.com/partners/517'

def get_page(id)
	partner = "https://access.kfit.com/partners/#{id}"
	if response = fetch(partner)
		return Nokogiri::HTML(response.body)
	end
end

def get_schedule_page(str)
	schedule_link = "https://access.kfit.com#{str}"
	if response = fetch(schedule_link)
		return Nokogiri::HTML(response.body)
	end
end

def get_script_node(page)
	node = page.xpath('//script[contains(text(),"var outlet_details")]')
	if node.empty?
		warn("cannot find var outlet_details in script nodes")
	else
		node.first.text
	end
end

def get_out_details(details_str)
	name,address,city = ""
	lat,lng = nil
	removed_var_name = details_str[(details_str.index('{')+1)..(details_str.rindex('};')-1)].strip
	rows = removed_var_name.split(",\n").map(&:strip)
	rows.map!{|r| /(.+):(.+)/.match(r).to_a.map(&:strip)}
	rows.each do |r|
		case r[1]
		when "name" then
			name = get_name(r[2])
		when "address" then
			address = get_address(r[2])
		when "city" then
			city = get_city(r[2])
		when "position" then
			lat,lng = get_latlng(r[2])
		else
		end
	end
	return name,address,city,lat,lng
end

def get_name(str)
	str.gsub(/\A'|'\Z/, '')
end

def get_address(str)
	str.gsub(/\A'|'\Z/, '')
end

def get_city(str)
	city = str.gsub(/\A'|'\Z/, '')
	city = city.gsub(/\W/,' ').split.map(&:capitalize).join(' ')
end

def get_latlng(str)
	pattern = /\d+.\d+/
	str.scan(pattern).map(&:to_f)
end

def get_avg_rating(page)
	rating = page.xpath("//div[@class='rating-average']/p/text()")
	unless rating.empty?
		rating.first.text.to_f
	else
		""
	end
end

def get_partner_details(page)
	contact = ""
	name,address,city,lat,lng = get_out_details(get_script_node(page))
	avg_rating = get_avg_rating(page)
	schedule_links = get_schedule_links(page)
	unless schedule_links.empty?
		contact = get_contact(schedule_links.first)
	end
	return name,address,city,lat,lng,avg_rating,contact
end

def get_schedule_links(page)
	links = page.css('a')
	links.map {|link| link.attribute('href').to_s}.uniq.grep(/\/schedules\/\d+/)
end

def get_contact(link)
	schedule_page = get_schedule_page(link)
	contact_sibling_node = schedule_page.xpath("//span[contains(text(),'Contact')]").first
	if contact_sibling_node
		contact = contact_sibling_node.next.text
		contact.gsub(/[[:space:]\-]/,'')
	else
		""
	end
end

def fetch(uri_string)
	response = Net::HTTP.get_response(URI(uri_string))
	case response
	when Net::HTTPSuccess then
		response
	when Net::HTTPRedirection then
		location = response['location']
		warn("redirected to #{location}")
	else
		nil
	end
end


def write_to_csv(data)
	
	# puts "Write results to csv..."
	CSV.open("file.csv", "ab") do |csv|
	  data.each do |row|
	  	csv<<row
	  end
	end
end

def get_data(starting,ending)
	partner_details = []
	id = starting
	begin
		while id <= ending do
			page = get_page(id)
			if page
				# puts "found #{id}! start to grab partner #{id} information..."
				details = get_partner_details(page).unshift(id)
				partner_details<<details
			end
			id += 1
		end
		write_to_csv(partner_details)
	rescue => e
		puts e.message
		puts e.backtrace.join("\n")
		puts "opps...error on id #{id}....save whatever to csv"
		write_to_csv(partner_details)
	end
end

# create new file
header = ["id","name","address","city","lat","lng","rating","contact"]
CSV.open("file.csv", "w",write_headers: true) do |csv|
	csv<<header
end
Benchmark.bm do  |x|
	x.report("multi:") do 
		thr1 = Thread.new{ get_data(161,165)}
		thr2 = Thread.new{ get_data(166,170)}
		thr1.join
		thr2.join
	end
	x.report("single:") {get_data(161,170)}
end

