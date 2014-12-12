# GAAH - Google Apps API Helper

## GAAH 0.5 Incompatibility Notice

Gaah version 0.5.x and later are NOT compatibel with Gaah 0.3.x
Gaah version 0.3 and above require OAuth2 flow - now a mandatory requirement from Google for new applications.

Please upgrade to 0.5 if you are planning to use OAuth2, otherwise stick with the 0.3.x branch version

### API Wrapper for Google Apps Marketplace

Currently supports:

![](https://developers.google.com/gdata/images/service_icons/gdata-contacts.png) Directory API (read-only)

![](https://developers.google.com/gdata/images/service_icons/gdata-calendar.png) Calendar API

### Example Code

```ruby
CLIENT_KEY = '000000000000.apps.googleusercontent.com'
CLIENT_SECRET = 'abcdefghijklmnopqrstuvwx'
REDIRECT_URI = 'http://localhost:3021/oauth2' #as set in your application in Google

# Setup
require 'gaah'
Gaah.setup_oauth2(CLIENT_KEY, CLIENT_SECRET, REDIRECT_URI)

# Obtain a valid OAuth2 token
gh = Gaah::ApiClient.new
authorization_url = gh.oauth2_authorization_uri

...redirect the user to login on the authorization_url. If authorized, the user will be redirected back with a valid access_code...

gh.access_code='#whatever_returned_by_google'

# Store your access token, refresh token somewhere for future usage

gh.storable_token #=> Store the token somewhere, db, etc

#... then in the future ...

gh = Gaah::OAuth.new(stored_token)

# Get users
users = Gaah::Directory::Api.users(gh)
user = users.first
user.id    # "https://apps-apis.google.com/a/feeds/example.com/user/2.0/bobert"
user.name  # "Bobert Jones"
user.title # "bobert"

# Get calendar events
events = user.events(gh)
event = events.first
event.title           # "Meeting with Joe"
event.when.start_time # 2013-04-16 13:00:00 -0400

# Get calendar resources *
rooms = Gaah::Resource::Api.resources(gh)
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