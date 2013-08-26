module Gaah
  module Calendar
    class When
      attr_accessor :start_time, :end_time
      def initialize(start_time, end_time)
        if start_time.is_a? Hash
          @start_time = Time.parse(start_time.values.first)
          @end_time   = Time.parse(end_time.values.first)
        else
          @start_time = Time.parse(start_time)
          @end_time   = Time.parse(end_time)
        end
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
