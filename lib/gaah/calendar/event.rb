module Gaah
  module Calendar
    class Event < Gaah::ApiModel
      attr_reader :updated, :summary, :description, :attendees, :when, :location, :creator, :transparency, :visibility, :ical_uid, :organizer, :sequence, :status, :url

      def initialize(json)
        store_json(json)

        @id           = json['id']
        @ical_uid     = json['iCalUID']
        @updated      = Time.parse(json['updated'])
        @summary      = json['summary'].to_s
        @description  = json['description'].to_s
        @location     = json['location'].to_s
        @creator      = Who.new(json['creator']) if json['creator']
        @when         = parse_when
        @attendees    = parse_attendees
        @transparency = json['transparency'].to_s
        @visibility   = json['visibility'] || 'default'
        @organizer    = Who.new(json['organizer'])
        @sequence     = json['sequence']
        @status       = json['status']
        @url          = json['htmlLink']
      end

      def to_json(*args)
        {
          id:           @id,
          updated:      @updated,
          summary:      @summary,
          description:  @description,
          location:     @location,
          creator:      @creator,
          when:         @when,
          attendees:    @attendees,
          transparency: @transparency,
          visibility:   @visibility,
          status:       @status,
          url:          @url,
          resources:    resources,
        }.to_json
      end

      def resources
        who.select(&:is_resource?)
      end

      # V2 -> V3
      def author;  creator;     end
      def content; description; end
      def title;   summary;     end
      def where;   location;    end
      def who;     attendees;   end

      def marshal_dump
        [@id, nil, @updated, @summary, @description, @location, @creator, @when,
         @attendees, @transparency, @visibility, @ical_uid, @organizer,
         @sequence, @status, @url]
      end

      def marshal_load(array)
        @id, _, @updated, @summary, @description, @location, @creator, @when,
          @attendees, @transparency, @visibility, @ical_uid, @organizer,
          @sequence, @status, @url = array
      end

      private

      def store_json(json)
        super
        unless @json['kind'] == "calendar#event"
          puts "Possible invalid event json - kind is #{ @json['kind'] }"
        end
      end

      def parse_when
        When.new(@json['start'], @json['end'])
      end

      def parse_attendees
        (@json['attendees'] || []).map {|attendee| Who.new(attendee) }
      end
    end
  end
end
