require 'open-uri'
require 'json'

i = 0
url = 'https://opendata.riga.lv/odata/service/KgApplications2'
loop do
  data = open(url).read

  open(File.expand_path("../../shared/data/applications/KgApplications2_#{i}.json", __dir__), 'wb') do |file|
    file << data
  end
  url = JSON.parse(data)['odata.nextLink']
  i += 1
  break unless url
end
