module Gaah
  module Calendar
    class When
      attr_accessor :start_time, :end_time
      def initialize(start_time, end_time)
        @start_time = Time.parse(start_time)
        @end_time   = Time.parse(end_time)
      end

      def to_json(*args)
        {
          start_time: @start_time,
          end_time:   @end_time,
        }.to_json
      end
    end
  end
end
