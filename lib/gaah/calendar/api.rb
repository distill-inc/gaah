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
          json   = ApiClient.instance.get(url, params)
          events = JSON.load(json)
          Event.batch_create(events['items'])
        end

        private

        def build_api_url(email)
          API_URL.sub('CAL_ID', email || 'default')
        end

        def build_api_params(xoauth_requestor_id, options)
          api_params = {
            xoauth_requestor_id: xoauth_requestor_id,
            alwaysIncludeEmail: true,
          }
          api_params[:orderBy]      = options.delete(:order_by)      || 'startTime'
          api_params[:singleEvents] = options.delete(:single_events) || true
          api_params[:timeMin]      = stringify(options.delete(:time_min))
          api_params[:timeMax]      = stringify(options.delete(:time_max))
          api_params
        end

        def stringify(time)
          time.nil? ? nil : DateTime.parse(time.strftime('%Y-%m-%dT17:00:00')).rfc3339
        end

       #API_URL = 'https://www.google.com/calendar/feeds/EMAIL/private/full'
        API_URL = 'https://www.googleapis.com/calendar/v3/calendars/CAL_ID/events'
      end
    end
  end
end
