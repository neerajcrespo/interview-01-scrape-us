require 'pry'
require 'net/http'
require 'nokogiri'
require 'json'
uri = 'https://access.kfit.com/schedules/614474'
partner = 'https://access.kfit.com/partners/517'
# content = "var outlet_details = {\n  id:          '764',\n  company_id:  '616',\n  name:        'The Club@Bukit Utama (Gym Access)',\n  address:     '1, Club Drive, Bukit Utama, Bandar Utama, 47800 Petaling Jaya',\n  city:        'kuala-lumpur',\n  position:    new google.maps.LatLng('3.15234', '101.602845'),\n  icon:        \"https://d2wwlnsocmwlmh.cloudfront.net/assets/kfit-marker-dc239a05fd85cf77e9aaa4731cda29ec8c965e35ae811394fc2321f97c2050ee.png\"\n};\n\n$(function(){\n  OutletMap.initialize(outlet_details);\n  $(window).off('.affix');\n  $(\"body\")\n    .removeClass(\"affix affix-top affix-bottom\")\n    .removeData(\"bs.affix\");\n});\n\nvar MAX_DISTANCE = 300;\nvar draggable = $('div#draggable');\n\nDraggable.create(draggable, {\n  onDrag:function(e) {\n    var x = this.target._gsTransform.x,\n        y = this.target._gsTransform.y,\n        distance = Math.sqrt(x * x + y * y);\n\n    if (distance > MAX_DISTANCE) {\n       this.endDrag(e);\n    }\n  },\n  onDragEnd:function() {\n    TweenMax.to(draggable, 1, {x:0, y:0, ease:Elastic.easeOut});\n  }\n});\n\n\n$(window).scroll(function() { \n    if ($(window).scrollTop() >= $(\".activity-image\").offset().top) {  \n      $(\".floating-bar\").addClass(\"reveal\");\n    } else if ($(window).scrollTop() < $(\".activity-image\").offset().top) {\n      $(\".floating-bar\").removeClass(\"reveal\");\n    } \n});"

# pattern = /var outlet_details\s*=\s*{.+};/m

# data = content.scan(pattern).first

# lala = data[(data.index('{')+1)..(data.rindex('};'))].strip
def get_script_node
end

def get_out_details_string
end

def get_address
end

def get_city
end

def get_latlng
end

def get_partner_details
	get_script_node
	get_out_details_string
	get_address
	get_city
	get_latlng
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
# if response = fetch(uri)
# 	page = Nokogiri::HTML(response.body)
# 	binding.pry
# end