module Gaah
  class HTTPForbidden < Exception;end
  class HTTPUnauthorized < Exception;end
  class HTTPBadRequest < Exception;end
  class UnknownHTTPException < Exception;end
end
