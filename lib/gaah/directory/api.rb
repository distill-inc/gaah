require 'gaah/directory/user'
require 'cgi'

module Gaah
  module Directory
    class Api
      class << self
        
        GOOGLE_DIRECTORY_URL="https://www.googleapis.com/admin/directory/v1/users"
        GOOGLE_DIRECTORY_USER_FIELDS="etag,nextPageToken,users(emails,id,isAdmin,isDelegatedAdmin,name,primaryEmail,suspended)"
        
        def users(oauth_client, domain)
          fetch_users(oauth_client, GOOGLE_DIRECTORY_URL, {"domain"=>domain, "fields"=>GOOGLE_DIRECTORY_USER_FIELDS})
        end

        private

        def fetch_users(oauth_client, url, params, retry_interval = 0)
          json   = ApiClient.new(oauth_client.access_token).get(url, params)
          parsed = JSON.load(json)

          current_users = parsed['users'].map{|user| Gaah::Directory::User.new(user)}
          next_page_token = parsed['nextPageToken']

          if next_page_token.nil?
            current_users
          else
            params['pageToken']=next_page_token
            current_users + fetch_users(oauth_client, url, params)
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