module Gaah
  module Resource
    class Resource < Gaah::ApiModel
      attr_reader :name, :email, :type

      def initialize(xml)
        store_xml(xml)

        @id = inner_text(:id)
        (@xml/'apps|property').each do |property|
          case property.attributes['name'].value
          when 'resourceCommonName' then @name  = property.attributes['value'].value
          when 'resourceEmail'      then @email = property.attributes['value'].value
          when 'resourceType'       then @type  = property.attributes['value'].value
          end
        end
      end

      def to_json(*args)
        {
          id: @id,
          name: @name,
          email: @email,
          type: @type,
        }.to_json
      end

      def marshal_dump
        [@id, @name, @email, @type]
      end

      def marshal_load(array)
        @id, @name, @email, @type = array
      end
    end
  end
end
