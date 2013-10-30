module Gaah
  module Calendar
    class Who
      attr_reader :name, :email, :resource
      def initialize(json)
        @name  = json['displayName'].to_s
        @email = json['email'].to_s
        @resource = !!json['resource']
      end

      def type
        case
        when is_resource? then "resource"
        when is_calendar? then "calendar"
        else "user"
        end
      end

      def is_resource?
        resource || email.end_with?('@resource.calendar.google.com')
      end

      def is_calendar?
        email.end_with?('@group.calendar.google.com')
      end

      def catch_all_user?
        self.email.to_s =~ /^\.@/
      end

      def to_json(*args)
        {
          name:  name,
          email: email,
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
