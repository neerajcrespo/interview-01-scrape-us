require 'open-uri'
require 'pry'
require 'mechanize'
require 'csv'

BASE_URL = "https://access.kfit.com"
CSV_URL = "kfit_partners2.csv"
$mechanize = Mechanize.new #let it act like a singleton

def get_details_from_detail_xpath(page) 
  city, partner_name, address, latitude, longitude, phone_number = ""
  #<ul class="list-unstyled studio-details"><li><span>Address</span><p>Unit 28 &amp; 30 - 2, Plaza Damansara, Jalan Medan Setia 2, Bukit Damansara, 50490 Kuala Lumpur, Wilayah Persekutuan Kuala Lumpur</p></li><li><span>Activities</span><p>Fat Lose in 60, SpartanXFit, XFit</p></li></ul></div></div><script type="text/javascript">var outlet_details
  xpath_data = page.parser.xpath('//script[contains(text(),"var outlet_details")]').first.children.first.to_html
  if xpath_data
    parsed_data = Hash.new
    parsed_data =  sanitize_xpath(xpath_data)
    if parsed_data
      city = parsed_data["city"] || ""
      partner_name = parsed_data["name"] || ""
      address = parsed_data["address"] || ""
      latitude = parsed_data["latitude"] || ""
      longitude = parsed_data["longitude"] || ""
    end
  end
  
  return city, partner_name, address, latitude, longitude
end

def sanitize_xpath(xpath_data)
  if xpath_data
    unzipped = xpath_data[(xpath_data.index('{')+1)..(xpath_data.index('};')-1)].strip.split(",\n").map(&:strip)
    data_hash = Hash.new
    unzipped.each do|field|
      key, value  = field.split(':').map(&:strip)
      case key
      when 'name'
        data_hash['name'] = value
      when 'address'
        data_hash['address'] = value
      when 'city'
        data_hash['city'] = value
      when 'position'
        data_hash['latitude'], data_hash['longitude'] = value[value.index('(')+1..value.index(')')-1].split(',').map(&:to_s)
      end
    end
    return data_hash
  end
end


def get_rating(page)
  page.at_css('.rating-average').children.first.children.text if page.at_css('.rating-average')
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

def csv_writer(data_array)
  CSV.open(CSV_URL,"ab") do |csv|
    data_array.each do |row|
      csv<<row
    end
  end
end

def id_to_csv_row(id)
  partner_url = BASE_URL.to_s+"/partners/#{id}"
  city, partner_name, address, latitude, longitude, average_rating, phone_number = ""
  begin 
    page = $mechanize.get(partner_url)
    if page
      puts "Collecting Resources for id #{id}"
      average_rating = get_rating(page)
      city, partner_name, address, latitude, longitude = get_details_from_detail_xpath(page)
      phone_number = scrap_phone_from_page(page)
      return [id, city, partner_name, address, latitude, longitude, average_rating, phone_number ]
    end
  rescue=>e 
    #do some rescue
  end
end

#add = get_address_and_phone_string_from_partner_page("https://access.kfit.com/partners/5")
#phone = get_phone_number_from_partner_page(url)


puts "Lets Scrap"

titles = ["id","city","partner_name","address","latitude","longitude","average_rating","contact"]
CSV.open(CSV_URL, "w",write_headers: true) do |csv|
  csv<<titles
end

data_array = []
for i in (1..20)
  data = id_to_csv_row(i)
  data_array << data if data
end

csv_writer(data_array)

puts "end"


