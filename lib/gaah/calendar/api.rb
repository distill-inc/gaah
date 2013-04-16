require 'gaah/calendar/event'
require 'gaah/calendar/when'
require 'gaah/calendar/who'

module Gaah
  module Calendar
    class Api
      class << self
        def events(xoauth_requestor_id, options)
          url    = build_api_url(options[:email])
          params = build_api_params(xoauth_requestor_id, options)
          xml    = ApiClient.instance.get(url, params)
          events = Nokogiri::XML(xml)/:entry
          Event.batch_create(events)
        end

        private

        def build_api_url(email)
          API_URL.sub('EMAIL', email || 'default')
        end

        def build_api_params(xoauth_requestor_id, options)
          api_params = { xoauth_requestor_id: xoauth_requestor_id }
          api_params[:orderby]      = options.delete(:order_by)      || 'starttime'
          api_params[:singleevents] = options.delete(:single_events) || true
          api_params[:sortorder]    = options.delete(:sort_order)    || 'a'
          api_params['start-min']   = stringify(options.delete(:start_min))
          api_params['start-max']   = stringify(options.delete(:start_max))
          api_params
        end

        def stringify(time)
          time.nil? ? nil : time.strftime('%Y-%m-%dT17:00:00')
        end

        API_URL = 'https://www.google.com/calendar/feeds/EMAIL/private/full'
      end
    end
  end
end
