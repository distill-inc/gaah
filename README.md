# GAAH - Google Apps API Helper

### API Wrapper for Google Apps Marketplace

Currently supports:

![](https://developers.google.com/gdata/images/service_icons/gdata-contacts.png) Provisioning API (read-only)

![](https://developers.google.com/gdata/images/service_icons/gdata-calendar.png) Calendar API

### Example Code

```ruby
CLIENT_KEY = '000000000000.apps.googleusercontent.com'
CLIENT_SECRET = 'abcdefghijklmnopqrstuvwx'
DOMAIN = 'example.com'

# Setup
require 'gaah'
Gaah.setup_oauth(CLIENT_KEY, CLIENT_SECRET)
Gaah.domain = DOMAIN

# Get users
users = Gaah::Provisioning::Api.users
user = users.first
user.id    # "https://apps-apis.google.com/a/feeds/example.com/user/2.0/bobert"
user.name  # "Bobert Jones"
user.title # "bobert"

# Get calendar events
xoauth_requestor_id = 'me@example.com'
events = user.events(xoauth_requestor_id)
event = events.first
event.title           # "Meeting with Joe"
event.when.start_time # 2013-04-16 13:00:00 -0400

# Get calendar resources *
rooms = Gaah::Resource::Api.resources
room = rooms.first
room.name # "U.S.S. Distill"
room.type # "Conference room"
```

* This API requires [admin API access found here](https://admin.google.com/AdminHome#SecuritySettings:flyout=apimanagement).

### Resources

Warning: Google documentation links sometimes move without good redirection.

* [Google Data APIs](https://developers.google.com/gdata/)
* [Google Apps Application APIs](https://developers.google.com/google-apps/app-apis)
* [Google Apps Administrative APIs](https://developers.google.com/google-apps/admin-apis)
* [Google Calendar API v2](https://developers.google.com/google-apps/calendar/v2/developers_guide_protocol)
* [Google Apps Provisioning API v2](https://developers.google.com/google-apps/provisioning/)
* [Google Apps Calendar Resource API](https://developers.google.com/admin-sdk/calendar-resource/)

### Todo
* Provisioning API is deprecated, use Directory API
* Error handling
