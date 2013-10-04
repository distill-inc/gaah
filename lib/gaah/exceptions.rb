module Gaah
  class HTTPForbidden < StandardError
    def initialize(msg = nil)
      info = "You do not have the necessary permissions to perform this action on this domain."
      super("#{info}#{msg.nil? ? '.' : ': '}#{msg}")
    end
  end

  class HTTPUnauthorized < StandardError
    def initialize(msg = nil)
      info = "This domain does not support Google Apps."
      super("#{info}#{msg.nil? ? '.' : ': '}#{msg}")
    end
  end

  class HTTPBadRequest < StandardError
    def initialize(msg = nil)
      info = "Unsupported action"
      super("#{info}#{msg.nil? ? '.' : ': '}#{msg}")
    end
  end

  class UnknownHTTPException < StandardError;end
end
