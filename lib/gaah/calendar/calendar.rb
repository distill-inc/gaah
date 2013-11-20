module Gaah
  module Calendar
    class Calendar < Gaah::ApiModel
      attr_reader :id, :summary, :description, :hidden, :selected, :primary, :time_zone, :color_id, :bg_color, :fg_color, :access_role

      def initialize(json)
        store_json(json)

        @id          = json['id']
        @summary     = json['summary']
        @description = json['description']
        @hidden      = json['hidden']
        @selected    = json['selected']
        @primary     = json['primary']
        @time_zone   = json['timeZone']
        @color_id    = json['colorId']
        @bg_color    = json['backgroundColor']
        @fg_color    = json['foregroundColor']
        @access_role = json['accessRole']
      end

      def to_json(*args)
        {
          id:          @id,
          summary:     @summary,
          description: @description,
          hidden:      @hidden,
          selected:    @selected,
          primary:     @primary,
          time_zone:   @time_zone,
          color_id:    @color_id,
          bg_color:    @bg_color,
          fg_color:    @fg_color,
          access_role: @access_role,
        }.to_json
      end

      def marshal_dump
        [@id, @summary, @description, @hidden, @selected, @primary, @time_zone, @color_id, @bg_color, @fg_color, @access_role]
      end

      def marshal_load(array)
        @id, @summary, @description, @hidden, @selected, @primary, @time_zone, @color_id, @bg_color, @fg_color, @access_role = array
      end
    end
  end
end
