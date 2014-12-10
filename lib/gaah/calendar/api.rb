require 'gaah/calendar/calendar'
require 'gaah/calendar/event'
require 'gaah/calendar/when'
require 'gaah/calendar/who'

module Gaah
  module Calendar
    class Api
      class << self
        # API: CalendarList: list
        def calendars(oauth_client, options = {}, retry_interval=0)
          url = "https://www.googleapis.com/calendar/v3/users/me/calendarList"
          params = {
            minAccessRole:       options[:min_access_role] || 'writer',
            showHidden:          options[:show_hidden]     || false,
          }
          calendars = JSON.load(ApiClient.new(oauth_client.access_token).get(url, params))
          Calendar.batch_create(calendars['items'])
        rescue Gaah::HTTPUnauthorized => e
          retry_interval+=1
          retry if retry_interval <= 3 && oauth_client.refresh_access_token!
          raise e
        end

        # API: Events#list
        def events(xoauth_requestor_id, options)
          url    = build_api_url(options[:email])
          params = build_events_api_params(xoauth_requestor_id, options)
          json   = ApiClient.instance.get(url, params)
          events = JSON.load(json)
          Event.batch_create(events['items'])
        end

        # API: Events#insert
        def create_event(xoauth_requestor_id, options)
          url    = build_api_url(options.delete(:email))
          params = { xoauth_requestor_id: xoauth_requestor_id }
          body   = build_create_api_body(options)
          json   = ApiClient.instance.post(url, params, body)

          Gaah::Calendar::Event.new(JSON.load(json))
        end

        # API: Events#get
        def event(xoauth_requestor_id, options)
          base   = build_api_url(options.delete(:email))
          id     = options.delete(:event_id)
          url    = "#{base}/#{id}"
          params = { xoauth_requestor_id: xoauth_requestor_id }
          json   = ApiClient.instance.get(url, params)

          Gaah::Calendar::Event.new(JSON.load(json))
        end

        def delete_event(xoauth_requestor_id, options)
          base   = build_api_url(options.delete(:email))
          id     = options.delete(:event_id)
          url    = "#{base}/#{id}"
          params = { xoauth_requestor_id: xoauth_requestor_id }
          ApiClient.instance.delete(url, params)
          { success: true }
        rescue Gaah::UnknownHTTPException => exception
          case exception.message
          when '404'
            { success: false, error: "Event was not found." }
          when '410'
            { success: false, error: "Event is already canceled." }
          end
        end

        private

        def build_api_url(email)
          API_URL.sub('CAL_ID', email || 'default')
        end

        def build_events_api_params(xoauth_requestor_id, options)
          api_params = {
            xoauth_requestor_id: xoauth_requestor_id,
            alwaysIncludeEmail: true,
          }
          api_params[:orderBy]      = options.delete(:order_by)      || 'startTime'
          api_params[:singleEvents] = options.delete(:single_events) || true
          api_params[:timeMin]      = dateify(options.delete(:time_min))
          api_params[:timeMax]      = dateify(options.delete(:time_max))
          api_params
        end

        # required options (heh):
        # email
        # start_time
        # end_time
        #
        # optional options:
        # summary
        # description
        # participants
        # resources
        def build_create_api_body(options)
          body = {}

          start_time  = { dateTime: options.delete(:start_time).xmlschema }
          end_time    = { dateTime: options.delete(:end_time  ).xmlschema }
          summary     = options.delete(:summary)
          description = options.delete(:description)

          attendees =
            attendeeify(options.delete(:participants), 'needsAction') +
            attendeeify(options.delete(:resources), 'accepted')

          body[:start]       = start_time
          body[:end]         = end_time
          body[:summary]     = summary     unless summary.nil?
          body[:description] = description unless description.nil?
          body[:attendees]   = attendees   unless attendees.empty?
          body
        end

        def dateify(time)
          time.nil? ? nil : DateTime.parse(time.strftime('%Y-%m-%dT17:00:00')).rfc3339
        end

        def attendeeify(emails, status)
          return [] if emails.nil?
          emails.map { |email| { email: email, responseStatus: status } }
        end

        API_URL = 'https://www.googleapis.com/calendar/v3/calendars/CAL_ID/events'
      end
    end
  end
end
