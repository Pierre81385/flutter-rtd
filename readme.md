![demo](https://github.com/Pierre81385/rtd_flutter/blob/main/rtd/lib/assets/ssr.gif?raw=true)

# CURRENTLY TESTING WITH TESTFLIGHT!!!

- if you'd like to try the app on your phone, contact me at pjb.den@gmail.com to join our testing group!

# Where's my train?

- An app to quickly find out where the train you want to board is currently located.
- Select a train line, and you are presented with a color coded list of trains currently running on that line.
  - Each train displays its headsign, current status, and where it's headed.
  - Each train displays when the information was last updated and when the next update will be requested.
  - Clicking on the location icon will take you to a Google Map view
    - Google Map view will show the current location of the train
      - Touching the marker will display the train headsign, status, and the station its headed to.
    - Each station that the train is scheduled to arrive at next is displayed with a marker
      - Touching the marker will display the station name and move it to the center of view
    - A color coded route (polyline) shows the projected path of the train
- Need to find the nearest station to catch your train? Each station has a walk icon. Touch this to see how far the staion is from your location!

## The deets

- GTFS Schedule Data Sets from https://www.rtd-denver.com/business-center/open-data/gtfs-developer-guide#gtfs-schedule-dataset
  - calendar, route, stop, stop time, and trip data
- GTFS-RT real time data feeds for alerts, trip updates, and vehicle information
- GoogleMaps API

## NOTE:

- activating the screen recording feature in iOS causes the app to crash.
