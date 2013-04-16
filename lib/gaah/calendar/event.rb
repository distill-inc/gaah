module Gaah
  module Calendar
    class Event < Gaah::ApiModel
      attr_reader :published, :updated, :title, :content, :status, :who, :when, :where, :author, :transparency, :visibility

      def initialize(xml)
        store_xml(xml)

        @id           = inner_text(:id)
        @published    = Time.parse(inner_text(:published))
        @updated      = Time.parse(inner_text(:updated))
        @title        = inner_text(:title)
        @content      = inner_text(:content)
        @status       = tag_value('gd|eventStatus')
        @where        = attr_value('gd|where', 'valueString')
        @author       = Who.new((@xml/:author).first)
        @when         = parse_when
        @who          = parse_who
        @transparency = tag_value('gd|transparency')
        @visibility   = tag_value('gd|visibility')
      end

      def to_json(*args)
        {
          id:           @id,
          published:    @published,
          updated:      @updated,
          title:        @title,
          content:      @content,
          status:       @status,
          where:        @where,
          author:       @author,
          when:         @when,
          who:          @who,
          transparency: @transparency,
          visibility:   @visibility,
        }.to_json
      end

      private

      def store_xml(xml)
        super
        unless @xml.attr('gd:kind') == "calendar#event"
          puts "Possible invalid event xml - gd:kind is #{ @xml.attr('gd:kind') }"
        end
      end

      def parse_when
        When.new(attr_value('> gd|when', 'startTime'), attr_value('> gd|when', 'endTime'))
      end

      def parse_who
        (@xml/'gd|who').map {|attendee| Who.new(attendee) }
      end
    end
  end
end
