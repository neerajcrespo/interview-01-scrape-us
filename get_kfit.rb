require 'open-uri'
require 'pry'
require 'mechanize'

BASE_URL = "https://access.kfit.com"
$mechanize = Mechanize.new #let it act like a singleton

def get_address_and_phone_string_from_partner_page(url)
  page = $mechanize.get(url)
  xpath_data, phone_data = ""
  #<ul class="list-unstyled studio-details"><li><span>Address</span><p>Unit 28 &amp; 30 - 2, Plaza Damansara, Jalan Medan Setia 2, Bukit Damansara, 50490 Kuala Lumpur, Wilayah Persekutuan Kuala Lumpur</p></li><li><span>Activities</span><p>Fat Lose in 60, SpartanXFit, XFit</p></li></ul></div></div><script type="text/javascript">var outlet_details
  if page 
    xpath_data = page.parser.xpath('//script[contains(text(),"var outlet_details")]').first.children.first.to_html
    binding.pry
    phone_data = get_phone_number_from_page(page)
  else
    puts "No Data or Page 404"
  end
  return xpath_data, phone_data
end

def make_address_string_to_csv_row(address_string)


end

def get_phone_number_from_page(page)
  all_links = page.css('a')
  if all_links
    all_links.each do |link|
      return link.attribute('href').to_s.strip  if link.attribute('href').to_s.match(/\/schedules\/\d+/)
    end
  end
end



add = get_address_and_phone_string_from_partner_page("https://access.kfit.com/partners/5")
#phone = get_phone_number_from_partner_page(url)
binding.pry
puts "end"


