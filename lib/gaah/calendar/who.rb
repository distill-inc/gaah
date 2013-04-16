module Gaah
  module Calendar
    class Who
      attr_reader :name, :email, :aliases
      def initialize(xml)
        @aliases = []

        case xml.name
        when 'author'
          @name  = (xml/:name).inner_text
          @email = (xml/:email).inner_text
        when 'who'
          @name  = xml.attr(:valueString)
          @email = xml.attr(:email)
        when 'entry'
          @name  = (xml/:title).inner_text
          (xml/'gd|email').each do |gd_email|
            email = gd_email.attr('address')
            @aliases << email
            @email = email if gd_email.attr('primary') == 'true'
          end
        else
          raise "Invalid person record #{xml.name}"
        end
      end

      def catch_all_user?
        self.email.to_s =~ /^\.@/
      end

      def to_json(*args)
        {
          name:    name,
          email:   email,
          aliases: aliases,
        }.to_json
      end

      def self.batch_process(xml, exclude_catch_all_user = true)
        (xml/:entry).map do |entry|
          who = new(entry)
          if exclude_catch_all_user && who.catch_all_user?
            nil
          else
            who
          end
        end.compact
      end
    end
  end
end
