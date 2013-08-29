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

    def get(base, query_params = {})
      make_request(:get, base, query_params)
    end

    def post(base, query_params = {}, body = {})
      make_request(:post, base, query_params, body)
    end

    private

    def make_request(method, url, params = {}, body = nil)
      url = "#{url}?#{QueryParams.encode(params)}" if params.keys.length > 0
      case method
      when :get
        response = @token.get(url, 'GData-Version' => '2.0')
      when :post
        response = @token.post(url, body.to_json, 'Content-Type' => 'application/json')
      else
        response = @token.request(method, url, 'GData-Version' => '2.0')
      end

      if response.is_a? Net::HTTPSuccess
        response.body
      elsif response.is_a? Net::HTTPFound
        url = response['Location']
        make_request(method, response['Location'], params, body)
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
