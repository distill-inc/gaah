module Gaah
  module Directory
    class User < Gaah::ApiModel
      attr_reader :id, :suspended, :admin, :user_name, :family_name, :given_name, :name, :email

      def initialize(entry)
        # Meta
        @id        = entry['id']
        @email     = entry['primaryEmail']
        @suspended = entry['suspended']
        @admin     = entry['isAdmin']

        # Name
        @user_name   = @email
        @name        = entry['name']['fullName']
        @family_name = entry['name']['familyName']
        @given_name  = entry['name']['givenName']
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
