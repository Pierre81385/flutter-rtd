![demo](https://github.com/Pierre81385/rtd_flutter/blob/main/rtd/lib/assets/current.gif?raw=true)

# Where's my train?

- Select a train line
- see the current trains running and their status at that time, with the time the information was last reported
- pull down the list to fetch the latest data to stay up to date
- check for service alerts
- see the next scheduled stops for that train with predicted arrival and departure times
- see on a google map where exactly that train is located

## Details

- GTFS Schedule Data Sets from https://www.rtd-denver.com/business-center/open-data/gtfs-developer-guide#gtfs-schedule-dataset
  - calendar, route, stop, stop time, and trip data
- GTFS-RT real time data feeds for alerts, trip updates, and vehicle information
- GoogleMaps API
