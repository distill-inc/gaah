require 'cgi'
require 'time'
require 'date'
require 'json'

require 'oauth'
require 'nokogiri'
require 'queryparams'

require 'gaah/api_client'
require 'gaah/api_model'
require 'gaah/calendar/api'
require 'gaah/provisioning/api'

module Gaah
  class << self
    attr_accessor :domain
    def setup_oauth(key, secret)
      ApiClient.setup_oauth(key, secret)
    end
  end
end
