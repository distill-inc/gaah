require 'gaah/provisioning/user'

module Gaah
  module Provisioning
    class Api
      class << self
        def users
          fetch_users("https://apps-apis.google.com/a/feeds/#{Gaah.domain}/user/2.0")
        end

        private

        def fetch_users(url)
          xml    = ApiClient.instance.get(url)
          parsed = Nokogiri::XML(xml)

          current_users = User.batch_create(parsed/:entry)
          next_link     = (parsed/'link[rel=next]').first

          if next_link.nil?
            current_users
          else
            url = next_link.attr('href')
            current_users + fetch_users(url)
          end
        end
      end
    end
  end
end
