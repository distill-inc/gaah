require 'gaah/resource/resource'

module Gaah
  module Resource
    class Api
      class << self
        def resources
          fetch_resources("https://apps-apis.google.com/a/feeds/#{Gaah.domain}/user/2.0")
        end

        private

        def fetch_resources(url)
          url    = "https://apps-apis.google.com/a/feeds/calendar/resource/2.0/#{Gaah.domain}"
          xml    = ApiClient.instance.get(url)
          parsed = Nokogiri::XML(xml)
          
          current_list = Resource.batch_create(parsed/:entry)
          next_link    = (parsed/'link[rel=next]').first

          if next_link.nil?
            current_list
          else
            url = next_link.attr('href')
            current_list + fetch_resources(url)
          end
        end
      end
    end
  end
end
