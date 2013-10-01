module Gaah
  module Provisioning
    class User < Gaah::ApiModel
      attr_reader :suspended, :admin, :title, :user_name, :family_name, :given_name, :name, :email

      def initialize(entry)
        store_xml(entry)

        # Meta
        @id        = inner_text(:id)
        @email     = parse_email
        @suspended = attr_value('apps|login', 'suspended') == 'true'
        @admin     = attr_value('apps|login', 'admin') == 'true'

        # Name
        @title       = inner_text(:title)
        @user_name   = attr_value('apps|login', 'userName')
        @family_name = attr_value('apps|name', 'familyName')
        @given_name  = attr_value('apps|name', 'givenName')
      end

      def parse_email
        email_link = (@xml/'gd|feedLink').select { |link|
          link.attr('rel').end_with?('user.emailLists')
        }.first
        return parse_login if email_link.nil?
        CGI::unescape(email_link.attr('href').split('recipient=').last)
      end

      def parse_login
        login = attr_value('apps|login', 'userName')
        "#{login}@#{Gaah.domain}"
      end

      def name
        "#{@given_name} #{@family_name}"
      end

      def events(xoauth_requestor_id, options = {})
        options[:email] = @email
        Gaah::Calendar::Api.events(xoauth_requestor_id, options)
      end

      def to_json(*args)
        {
          id:          @id,
          suspended:   @suspended,
          admin:       @admin,
          title:       @title,
          user_name:   @user_name,
          family_name: @family_name,
          given_name:  @given_name,
          name:        @name,
        }.to_json
      end

      def marshal_dump
        [@id, @suspended, @admin, @title, @user_name, @family_name, @given_name, @name, @email]
      end

      def marshal_load(array)
        @id, @suspended, @admin, @title, @user_name, @family_name, @given_name, @name, @email = array
      end
    end
  end
end
