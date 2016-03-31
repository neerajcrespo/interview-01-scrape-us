require 'pry'
require 'net/http'
require 'nokogiri'
uri = 'https://access.kfit.com/schedules/614474'
partner = 'https://access.kfit.com/partners/517'

def get_script_node
	puts "searching script nodes..."
	partner = 'https://access.kfit.com/partners/517'
	response = fetch(partner)
	page = Nokogiri::HTML(response.body)
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

def get_partner_details
	name,address,city,lat,lng = get_out_details(get_script_node)
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
get_partner_details
# if response = fetch(uri)
# 	page = Nokogiri::HTML(response.body)
# 	binding.pry
# end