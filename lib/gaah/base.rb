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
require 'gaah/directory/api'
require 'gaah/resource/api'
require 'gaah/exceptions'
require 'gaah/gaah_oauth'

module Gaah
  class << self
    attr_accessor :domain
    def setup_oauth2(key, secret, redirect_uri = nil)
      Gaah::OAuth.setup_oauth2(key, secret, redirect_uri)
    end
  end
end
