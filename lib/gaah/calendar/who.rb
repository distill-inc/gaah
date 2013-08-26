module Gaah
  module Calendar
    class Who
      attr_reader :name, :email
      def initialize(json)
        @name  = json['displayName'].to_s
        @email = json['email'].to_s
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
