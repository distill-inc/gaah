module Gaah
  module Directory
    class User < Gaah::ApiModel
      attr_reader :id, :suspended, :admin, :user_name, :family_name, :given_name, :name, :email

      def initialize(entry)
        # Meta
        @id        = entry['id']
        @email     = entry['primaryEmail']
        
        if @email.nil? && entry['emails'] && entry['emails'].count > 0
          @email = entry['emails'].first['address']
          @email ||= entry['emails'].first['value']
        end
        
        @suspended = entry['suspended']
        @admin     = entry['isAdmin']

        # Name
        @user_name   = @email
        @family_name = entry['name']['familyName']
        @given_name  = entry['name']['givenName']
        @name        = entry['name']['fullName'] || "#{@given_name} #{@family_name}"
      end

      def events(oauth_client, options = {})
        options[:email] = @email
        Gaah::Calendar::Api.events(oauth_client, options)
      end

      def to_json(*args)
        {
          id:          @id,
          suspended:   @suspended,
          admin:       @admin,
          email:       @email,
          user_name:   @user_name,
          family_name: @family_name,
          given_name:  @given_name,
          name:        @name,
        }.to_json
      end

      def marshal_dump
        [@id, @suspended, @admin, @user_name, @family_name, @given_name, @name, @email]
      end

      def marshal_load(array)
        @id, @suspended, @admin, @user_name, @family_name, @given_name, @name, @email = array
      end
    end
  end
end
