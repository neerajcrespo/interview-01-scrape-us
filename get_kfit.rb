require 'open-uri'
require 'nokogiri'
require 'pry'

url = "https://access.kfit.com/partners/5"
#sample
#<div class="sidebar-box outlet-details-partner"><div class="outlet-data"><ul class="list-unstyled studio-details"><li><span>Address</span><p>Unit 28 &amp; 30 - 2, Plaza Damansara, Jalan Medan Setia 2, Bukit Damansara, 50490 Kuala Lumpur, Wilayah Persekutuan Kuala Lumpur</p></li><li><span>Activities</span><p>Fat Lose in 60, SpartanXFit, XFit</p></li></ul></div></div><script type="text/javascript">var outlet_details

html = open(url)
doc = Nokogiri::HTML(html)

details = doc.css('.studio-details')
puts details.first.children.first.children.last
binding.pry
details.first.children.first.children.each do |f|
  binding.pry
end

