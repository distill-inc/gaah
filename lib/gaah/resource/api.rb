require 'gaah/resource/resource'

module Gaah
  module Resource
    class Api
      class << self
        
        GOOGLE_CALENDAR_URL = 'https://apps-apis.google.com/a/feeds/calendar/resource/2.0/'
        
        def resources(oauth_client, domain)
          fetch_resources(oauth_client, "#{GOOGLE_CALENDAR_URL}#{domain}")
        end

        private

        def fetch_resources(oauth_client, url, retry_interval = 0)
          xml    = ApiClient.new(oauth_client.access_token).get(url, {})
          parsed = Nokogiri::XML(xml)

          current_list = Resource.batch_create(parsed/:entry)
          next_link    = (parsed/'link[rel=next]').first

          if next_link.nil?
            current_list
          else
            url = next_link.attr('href')
            current_list + fetch_resources(oauth_client, url)
          end
        
        rescue Gaah::HTTPUnauthorized => e
          retry_interval+=1
          retry if retry_interval <= 3 && oauth_client.refresh_access_token!
          raise e
        end
      end
    end
  end
end
