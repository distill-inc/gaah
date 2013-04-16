require 'gaah/provisioning/user'

module Gaah
  module Provisioning
    class Api
      class << self
        def users
          url   = "https://apps-apis.google.com/a/feeds/#{Gaah.domain}/user/2.0"
          xml   = ApiClient.instance.get(url)
          users = Nokogiri::XML(xml)/:entry
          User.batch_create(users)
        end
      end
    end
  end
end
