module Gaah
  class ApiClient
    class << self
      attr_accessor :consumer_key, :consumer_secret, :instance

      def setup_oauth(key, secret)
        @@consumer_key = key
        @@consumer_secret = secret
        true
      end

      def not_setup?
        @@consumer_key.nil? || @@consumer_secret.nil?
      end

      def instance
        @@instance ||= new
      end
    end

    def initialize
      raise 'consumer_key and consumer_secret not set' if ApiClient.not_setup?
      oauth_consumer = OAuth::Consumer.new(@@consumer_key, @@consumer_secret)
      @token = OAuth::AccessToken.new(oauth_consumer)
    end

    def get(base, query_params={})
      url = base
      url = "#{base}?#{QueryParams.encode(query_params)}" if query_params.keys.length > 0
      make_request(:get, url)
    end

    private

    def make_request(method, url)
      response = @token.request(method, url, 'GData-Version' => '2.0')

      if response.is_a? Net::HTTPSuccess
        response.body
      elsif response.is_a? Net::HTTPFound
        url = response['Location']
        make_request(method, response['Location'])
      elsif response.is_a? Net::HTTPForbidden
        raise Gaah::HTTPForbidden
      elsif response.is_a? Net::HTTPUnauthorized
        raise Gaah::HTTPUnauthorized
      else
        # TODO: error handling
        response
      end
    end
  end
end
