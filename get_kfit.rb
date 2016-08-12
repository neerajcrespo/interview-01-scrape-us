require 'open-uri'
require 'pry'
require 'mechanize'

BASE_URL = "https://access.kfit.com"
$mechanize = Mechanize.new #let it act like a singleton

def get_address_and_phone_string_from_partner_page(page) 
  address_data, phone_data = ""
  #<ul class="list-unstyled studio-details"><li><span>Address</span><p>Unit 28 &amp; 30 - 2, Plaza Damansara, Jalan Medan Setia 2, Bukit Damansara, 50490 Kuala Lumpur, Wilayah Persekutuan Kuala Lumpur</p></li><li><span>Activities</span><p>Fat Lose in 60, SpartanXFit, XFit</p></li></ul></div></div><script type="text/javascript">var outlet_details
  if page 
    address_data = page.parser.xpath('//script[contains(text(),"var outlet_details")]').first.children.first.to_html
    phone_data = scrap_phone_from_page(page)
  else
    puts "No Data or Page 404"
    return nil
  end
  return address_data, phone_data
end

def extract_row_from_address_xpath_string(address_string)

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


def id_to_csv_row_builder(id)
  partner_url = BASE_URL.to_s+"/partners/#{id}"
  begin 
    page = $mechanize.get(partner_url)
    if page
      puts "page exist #{id}"
    else
      puts "page No exist with this resource id"
    end
  rescue=>e 
    puts "page not found with id #{id}"
  end
end

#add = get_address_and_phone_string_from_partner_page("https://access.kfit.com/partners/5")
#phone = get_phone_number_from_partner_page(url)
for i in (1..10)
  id_to_csv_row_builder(i)
end
binding.pry
puts "end"


