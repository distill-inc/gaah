require 'gaah/calendar/calendar'
require 'gaah/calendar/event'
require 'gaah/calendar/when'
require 'gaah/calendar/who'

module Gaah
  module Calendar
    class Api
      class << self

        CALENDAR_LIST_URL = "https://www.googleapis.com/calendar/v3/users/me/calendarList"
        CALENDAR_API_URL = 'https://www.googleapis.com/calendar/v3/calendars/CAL_ID/events'

        # API: CalendarList: list
        def calendars(oauth_client, options = {}, retry_interval=0)
          params = {
            minAccessRole:       options[:min_access_role] || 'writer',
            showHidden:          options[:show_hidden]     || false,
          }
          calendars = JSON.load(ApiClient.new(oauth_client.access_token).get(CALENDAR_LIST_URL, params))
          Calendar.batch_create(calendars['items'])
        rescue Gaah::HTTPUnauthorized => e
          retry_interval+=1
          retry if retry_interval <= 3 && oauth_client.refresh_access_token!
          raise e
        end

        # API: Events#list
        def events(oauth_client, options, retry_interval=0)
          modifiable_options = options.dup  #build_events_api_params modifies options, giving side effects for retry

          url    = build_api_url(modifiable_options[:email])
          params = build_events_api_params(modifiable_options)
          json   = ApiClient.new(oauth_client.access_token).get(url, params)
          events = JSON.load(json)
          Event.batch_create(events['items'])
        rescue Gaah::HTTPUnauthorized => e
          retry_interval+=1
          retry if retry_interval <= 3 && oauth_client.refresh_access_token!
          raise e
        end

        # API: Events#insert
        def create_event(oauth_client, options, retry_interval=0)
          modifiable_options = options.dup  #build_events_api_params modifies options, giving side effects for retry

          url    = build_api_url(modifiable_options.delete(:email))
          params = {}
          params[:sendNotifications] = true if modifiable_options.delete(:send_notifications)
          body   = build_create_api_body(modifiable_options)
          json   = ApiClient.new(oauth_client.access_token).post(url, params, body)

          Gaah::Calendar::Event.new(JSON.load(json))
        rescue Gaah::HTTPUnauthorized => e
          retry_interval+=1
          retry if retry_interval <= 3 && oauth_client.refresh_access_token!
          raise e
        end

        # API: Events#update
        def update_event(oauth_client, options, retry_interval=0)
          modifiable_options = options.dup  #build_events_api_params modifies options, giving side effects for retry

          url    = build_api_url(modifiable_options.delete(:email)) + "/#{modifiable_options.delete(:id)}"
          params = {}
          params[:sendNotifications] = true if modifiable_options.delete(:send_notifications)
          body   = build_create_api_body(modifiable_options)
          json   = ApiClient.new(oauth_client.access_token).put(url, params, body)

          Gaah::Calendar::Event.new(JSON.load(json))
        rescue Gaah::HTTPUnauthorized => e
          retry_interval+=1
          retry if retry_interval <= 3 && oauth_client.refresh_access_token!
          raise e
        end

        # API: Events#get
        def event(oauth_client, options, retry_interval=0)
          modifiable_options = options.dup  #build_events_api_params modifies options, giving side effects for retry

          base   = build_api_url(modifiable_options.delete(:email))
          id     = modifiable_options.delete(:event_id)
          url    = "#{base}/#{id}"
          params = {}
          json   = ApiClient.new(oauth_client.access_token).get(url, params)

          Gaah::Calendar::Event.new(JSON.load(json))
        rescue Gaah::HTTPUnauthorized => e
          retry_interval+=1
          retry if retry_interval <= 3 && oauth_client.refresh_access_token!
          raise e
        end

        def delete_event(oauth_client, options, retry_interval=0)
          modifiable_options = options.dup  #build_events_api_params modifies options, giving side effects for retry

          base   = build_api_url(modifiable_options.delete(:email))
          id     = modifiable_options.delete(:event_id)
          url    = "#{base}/#{id}"
          params = {}
          params[:sendNotifications] = true if modifiable_options.delete(:send_notifications)

          ApiClient.new(oauth_client.access_token).delete(url, params)
          { success: true }
        rescue Gaah::HTTPUnauthorized => e
          retry_interval+=1
          retry if retry_interval <= 3 && oauth_client.refresh_access_token!
          raise e
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
          CALENDAR_API_URL.sub('CAL_ID', email || 'default')
        end

        def build_events_api_params(options)
          api_params = {
            alwaysIncludeEmail: true,
          }
          api_params[:orderBy]      = options.delete(:order_by)      || 'startTime'
          api_params[:singleEvents] = options.delete(:single_events) || true
          api_params[:timeMin]      = dateify(options.delete(:time_min))  if options[:time_min]
          api_params[:timeMax]      = dateify(options.delete(:time_max))  if options[:time_max]
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
          location    = options.delete(:location)

          attendees =
            attendeeify(options.delete(:participants), 'needsAction') +
            attendeeify(options.delete(:resources), 'accepted')

          body[:start]       = start_time
          body[:end]         = end_time
          body[:summary]     = summary     unless summary.nil?
          body[:description] = description unless description.nil?
          body[:attendees]   = attendees   unless attendees.empty?
          body[:location]    = location    unless location.nil?
          body
        end

        def dateify(time)
          time.nil? ? nil : DateTime.parse(time.strftime('%Y-%m-%dT17:00:00')).rfc3339
        end

        def attendeeify(emails, status)
          return [] if emails.nil?
          emails.map { |email| { email: email, responseStatus: status } }
        end

      end
    end
  end
end
