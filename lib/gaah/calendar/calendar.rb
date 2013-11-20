module Gaah
  module Calendar
    class Calendar < Gaah::ApiModel
      attr_reader :id, :summary, :description, :time_zone, :color_id, :bg_color, :fg_color, :selected, :access_role

      def initialize(json)
        store_json(json)

        @id          = json['id']
        @summary     = json['summary']
        @description = json['description']
        @time_zone   = json['timeZone']
        @color_id    = json['colorId']
        @bg_color    = json['backgroundColor']
        @fg_color    = json['foregroundColor']
        @selected    = json['selected']
        @access_role = json['accessRole']
      end

      def to_json(*args)
        {
          id:          @id,
          summary:     @summary,
          description: @description,
          time_zone:   @time_zone,
          color_id:    @color_id,
          bg_color:    @bg_color,
          fg_color:    @fg_color,
          selected:    @selected,
          access_role: @access_role,
        }.to_json
      end

      def marshal_dump
        [@id, @summary, @description, @time_zone, @color_id, @bg_color, @fg_color, @selected, @access_role]
      end

      def marshal_load(array)
        @id, @summary, @description, @time_zone, @color_id, @bg_color, @fg_color, @selected, @access_role = array
      end
    end
  end
end
