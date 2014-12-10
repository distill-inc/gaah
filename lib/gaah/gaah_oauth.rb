require 'signet/oauth_2/client'
require 'gaah/exceptions'

module Gaah
  class OAuth
    
    OAUTH2_SCOPES=['https://apps-apis.google.com/a/feeds/calendar/resource/',     #access to calendars
                 # 'https://www.googleapis.com/auth/calendar.readonly',            #access to calendars read only
                  'https://www.googleapis.com/auth/admin.directory.user',         #access to users
                  'https://www.googleapis.com/auth/admin.directory.user.readonly'] #access to users read only
                  
    AUTHORIZATION_URI='https://accounts.google.com/o/oauth2/auth'
    TOKEN_CREDENTIALS_URI='https://accounts.google.com/o/oauth2/token'
    
    class << self

       attr_accessor :consumer_key, :consumer_secret

       def setup_oauth2(key, secret, redirect_uri = nil)
         @@consumer_key = key
         @@consumer_secret = secret
         @@redirect_uri = redirect_uri
         true
       end
       
       def not_setup?
         @@consumer_key.nil? || @@consumer_secret.nil?
       end
       
    end
    
    def initialize(options = {})
     @oauth_client = Signet::OAuth2::Client.new(
        :authorization_uri => AUTHORIZATION_URI,
        :token_credential_uri => TOKEN_CREDENTIALS_URI,
        :client_id => @@consumer_key,
        :client_secret => @@consumer_secret,
        :scope => OAUTH2_SCOPES.join(' '),
        :redirect_uri => @@redirect_uri
      )
      
      if options && !options.empty?
        %w(code expiry refresh_token access_token id_token state expires_in expires_at).each do |field|
          oauth2_option = options[field] || options[field.to_sym]
          next if oauth2_option.nil?
        
          @oauth_client.send("#{field}=", oauth2_option)
        end
      end
    end
    
    # Used to start the handshake with the OAuth2 provider (Google)
    def authorization_uri
      @oauth_client.authorization_uri
    end

    # Used to close the handshake with the OAuth2 provider (Google)
    def access_code=(access_code)
      @oauth_client.code = access_code
      fetch_access_token!
    rescue Signet::AuthorizationError => e
      raise Gaah::HTTPUnauthorized.new(e.message)
    end  
    
    def access_token
      @oauth_client.access_token
    end

    def expired?
      @oauth_client.expired?
    end

    def expires_at
      @oauth_client.expires_at
    end
    
    def storable_token
      {"access_token"=>@oauth_client.access_token, "token_type"=>"Bearer", "expires_at"=> (@oauth_client.expires_at ? @oauth_client.expires_at.to_i : nil), "refresh_token"=>@oauth_client.refresh_token} 
    end

    def refresh_access_token!
      @oauth_client.refresh!
    rescue Signet::AuthorizationError => e
      raise Gaah::HTTPUnauthorized.new(e.message)
    end
    
    private
    
    def fetch_access_token!
      @oauth_client.fetch_access_token!
    end
        
  end
end