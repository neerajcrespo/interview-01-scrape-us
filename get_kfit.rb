require 'open-uri'
require 'pry'
require 'mechanize'

BASE_URL = "https://access.kfit.com"
$mechanize = Mechanize.new #let it act like a singleton

def get_address_and_phone_string_from_partner_page(page) 
  city, partner_name, address, latitude, longitude, phone_number = ""
  #<ul class="list-unstyled studio-details"><li><span>Address</span><p>Unit 28 &amp; 30 - 2, Plaza Damansara, Jalan Medan Setia 2, Bukit Damansara, 50490 Kuala Lumpur, Wilayah Persekutuan Kuala Lumpur</p></li><li><span>Activities</span><p>Fat Lose in 60, SpartanXFit, XFit</p></li></ul></div></div><script type="text/javascript">var outlet_details
  xpath_data = page.parser.xpath('//script[contains(text(),"var outlet_details")]').first.children.first.to_html
  if xpath_data
    parsed_data = Hash.new
    parsed_data =  sanitize_xpath(xpath_data)
    phone_number = scrap_phone_from_page(page)
    rating = get_rating(page)
  end
  

  return city, partner_name, address, latitude, longitude, phone_number
end

def sanitize_xpath(xpath_data)
  if address_string
    unzipped = address_string[(address_string.index('{')+1)..(address_string.index('};')-1)].strip.split(",\n").map(&:strip)
    data_hash = Hash.new
    unzipped.each do|field|
      key = field.first.to_s.strip
      value = field.last.to_s.strip
      case key
      when 'name'
        data_hash['name'] = value
      when 'address'
        data_hash['address'] = value
      when 'city'
        data_hash['city'] = value
      when 'position'
        data_hash['latitude'], data_hash['longitude'] = value[value.index('(')..value.index[')']].split(',').map(&:to_s)
      end
    end
    return data_hash
  end
end


def get_rating(page)


end

def scrap_phone_from_page(page)
  linked_page = get_link_page(page)
  if linked_page
    link_page_url = BASE_URL+linked_page.to_s
    linked_page_html= $mechanize.get(link_page_url)
    if linked_page_html and (contact_span = linked_page_html.parser.xpath("//span[contains(text(),'Contact')]").first)
      return contact_span.next.text.to_s.strip || ""
    end
  end
end

def get_link_page(page)
  all_links = page.css('a')
  if all_links
    all_links.each do |link|
      return link.attribute('href').to_s.strip  if link.attribute('href').to_s.match(/\/schedules\/\d+/)
    end
  end
end


def id_to_csv_row(id)
  partner_url = BASE_URL.to_s+"/partners/#{id}"
  city, partner_name, address, latitude, longitude, average_rating, phone_number = ""
  begin 
    page = $mechanize.get(partner_url)
    if page
      city, partner_name, address, latitude, longitude = get_address_and_phone_string_from_partner_page(page)
    else
      puts "page No exist with this resource id"
    end
  rescue=>e 
    puts "page not found with id #{id}"
  end
end

#add = get_address_and_phone_string_from_partner_page("https://access.kfit.com/partners/5")
#phone = get_phone_number_from_partner_page(url)

id_to_csv_row(5)
binding.pry
puts "end"


