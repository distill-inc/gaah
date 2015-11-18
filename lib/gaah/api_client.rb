require 'signet/oauth_2/client'

module Gaah
  class ApiClient

    def initialize(access_token)
      raise 'missing access_token' if access_token.nil?
      @access_token = access_token
    end

    def get(base, query_params = {})
      make_request(:get, base, query_params)
    end

    def delete(base, query_params = {})
      make_request(:delete, base, query_params)
    end

    def post(base, query_params = {}, body = {})
      make_request(:post, base, query_params, body)
    end

    def put(base, query_params = {}, body = {})
      make_request(:put, base, query_params, body)
    end

    private

    def handle_response(uri, response)

      if response.success?
        response.body
      elsif response.status == 302 || response.status == 301
        url = response.headers['Location']
        new_uri = URI(url)

        make_request(method, (new_uri.absolute?) ? url : (uri.scheme + "://" + uri.host + url), params, body)
      elsif response.status == 403
        raise Gaah::HTTPForbidden
      elsif response.status == 401
        raise Gaah::HTTPUnauthorized
      elsif response.status == 400
        raise Gaah::HTTPBadRequest
      else
        raise Gaah::UnknownHTTPException.new(response.status.to_s)
      end

    end

    def make_request(method, url, params = {}, body = nil)
      url = "#{url}?#{QueryParams.encode(params)}" if params.keys.length > 0
      uri = URI(url)

      http_connection = Faraday.new(uri.scheme + "://" + uri.host)
      headers = { 'Cache-Control' => 'no-store', 'GData-Version' => '2.0', 'Authorization' => ::Signet::OAuth2.generate_bearer_authorization_header( @access_token, nil ) }

      response = case method
        when :get
          http_connection.get do |req|
            req.url url, params
            req.headers= headers
          end
        when :delete
          http_connection.delete do |req|
            req.url url, params
            req.headers= headers
          end
        when :post
          headers['Content-Type'] = 'application/json'

          http_connection.post do |req|
            req.url url, params
            req.headers= headers
            req.body = body.to_json
          end
        when :put
          headers['Content-Type'] = 'application/json'

          http_connection.put do |req|
            req.url url, params
            req.headers= headers
            req.body = body.to_json
          end
        else
          raise Gaah::UnknownHTTPException.new("Unknown HTTP Method #{method}")
        end

      handle_response uri, response
    end
  end
end
