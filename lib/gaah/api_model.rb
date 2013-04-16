module Gaah
  class ApiModel
    attr_reader :id

    def self.batch_create(xml)
      (xml/:entry).map(&method(:new))
    end

    protected

    def ==(other)
      @id == other.id
    end

    private

    def store_xml(xml)
      @xml = xml.is_a?(String) ? Nokogiri::XML(xml) : xml
    end

    def inner_text(tag)
      (@xml/tag).inner_text
    end

    def attr_value(tag, attribute = 'value')
      node = (@xml/tag).first
      return nil if node.nil?
      attr = node.attr(attribute)
      attr.respond_to?(:value) ? attr.value : attr
    end

    def tag_value(tag)
      attr_value(tag).split('.').last
    end

    def inspect
      "#<#{self.class}:#{object_id}>"
    end
  end
end
