import 'package:flutter/material.dart';
import 'package:gtfs_realtime_bindings/gtfs_realtime_bindings.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rtd/gtfs/map.dart';
import '../data_sets/route_data.dart';
import '../data_sets/stop_data.dart';
import '../data_sets/trip_data.dart';

class RTDFeed extends StatefulWidget {
  const RTDFeed({required this.vehicle, super.key});
  final String vehicle;

  @override
  State<RTDFeed> createState() => _RTDFeedState();
}

class _RTDFeedState extends State<RTDFeed> {
  late List<FeedEntity> alerts = [];
  late List<FeedEntity> trips = [];
  late List<FeedEntity> vehicles = [];

  late GlobalKey<ScaffoldState> _scaffoldKey;
  late String stopSelected;

  final status = ["Incoming at", "Stopped at", "In transit to"];

  final snack = const SnackBar(
    content: Text('Data Refreshed'),
  );

  void AlertFeed() async {
    final url = Uri.parse('https://www.rtd-denver.com/files/gtfs-rt/Alerts.pb');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final feedMessage = FeedMessage.fromBuffer(response.bodyBytes);

      print('Number of Alerts: ${feedMessage.entity.length}.');

      setState(() {
        alerts = feedMessage.entity;
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  void TripFeed() async {
    final url =
        Uri.parse('https://www.rtd-denver.com/files/gtfs-rt/TripUpdate.pb');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final feedMessage = FeedMessage.fromBuffer(response.bodyBytes);

      print('Number of Trips Found: ${feedMessage.entity.length}.');

      setState(() {
        trips = feedMessage.entity;
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  void VehicaleFeed() async {
    final url = Uri.parse(
        'https://www.rtd-denver.com/files/gtfs-rt/VehiclePosition.pb');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final feedMessage = FeedMessage.fromBuffer(response.bodyBytes);

      print('Number of Vehicles Found: ${feedMessage.entity.length}.');

      setState(() {
        vehicles = feedMessage.entity;
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Widget _buildPopupDialog(BuildContext context, list) {
    List<FeedEntity> thisList = list;

    return AlertDialog(
      title: const Text('Service Alerts'),
      content: list.length > 0
          ? Container(
              width: double.maxFinite,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: thisList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      isThreeLine: true,
                      title: Column(
                        children: [
                          Text(thisList[index]
                              .alert
                              .descriptionText
                              .translation[0]
                              .text
                              .toString()),
                          const SizedBox(
                            height: 10,
                            width: 100,
                          ),
                          thisList[index].alert.activePeriod[0].start.toInt() >
                                  0
                              ? Text(
                                  "Starting ${DateFormat.yMMMMd('en_US').format(DateTime.fromMillisecondsSinceEpoch(thisList[index].alert.activePeriod[0].start.toInt() * 1000))}")
                              : const SizedBox(),
                          const SizedBox(
                            height: 10,
                            width: 100,
                          ),
                          thisList[index].alert.activePeriod[0].end.toInt() > 0
                              ? Text(
                                  "Ending ${DateFormat.yMMMMd('en_US').format(DateTime.fromMillisecondsSinceEpoch(thisList[index].alert.activePeriod[0].end.toInt() * 1000))}")
                              : const SizedBox(),
                        ],
                      ),
                      subtitle: Text(thisList[index]
                          .alert
                          .headerText
                          .translation[0]
                          .text
                          .toString()),
                    );
                  }),
            )
          : const Text('There are no service alerts at this time.'),
      actions: <Widget>[
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  @override
  void initState() {
    AlertFeed();
    VehicaleFeed();
    TripFeed();
    _scaffoldKey = GlobalKey();
    stopSelected = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () {
            return Future.delayed(
              const Duration(seconds: 1),
              () {
                //refresh feed data and reload on state change
                setState(() {
                  AlertFeed();
                  VehicaleFeed();
                  TripFeed();
                });

                // showing snackbar
                ScaffoldMessenger.of(context).showSnackBar(snack);
              },
            );
          },
          child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: vehicles.length,
              itemBuilder: (BuildContext context, int index) {
                List<TripUpdate_StopTimeUpdate> stops = [];

                int tripIndex = trips.indexWhere((element) =>
                    element.tripUpdate.trip.tripId ==
                    vehicles[index].vehicle.trip.tripId);
                if (tripIndex == -1) {
                  print('no trip data');
                } else {
                  for (var i = 0;
                      i <= trips[tripIndex].tripUpdate.stopTimeUpdate.length;
                      i++) {
                    stops = trips[tripIndex].tripUpdate.stopTimeUpdate.toList();
                  }
                }

                //get route data of the selected train/bus
                return routeData[
                            vehicles[index].vehicle.trip.routeId.toString()] ==
                        null
                    ? const SizedBox()
                    : widget.vehicle == "select"
                        ? const SizedBox()
                        : routeData[vehicles[index]
                                        .vehicle
                                        .trip
                                        .routeId
                                        .toString()]!["route_short_name"]
                                    .toString() ==
                                widget.vehicle
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 5,
                                        blurRadius: 7,
                                        offset: const Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: const BorderRadius
                                                    .only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10),
                                                bottomLeft: Radius.circular(10),
                                                bottomRight:
                                                    Radius.circular(10)),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 5,
                                                blurRadius: 7,
                                                offset: const Offset(0,
                                                    3), // changes position of shadow
                                              ),
                                            ],
                                          ),
                                          child: ListTile(
                                            isThreeLine: true,
                                            //name of the route selected
                                            leading: IconButton(
                                              onPressed: () {
                                                //popup for schedule list here
                                              },
                                              icon: const Icon(
                                                  Icons.schedule_outlined),
                                            ),
                                            //descriptive name of the route
                                            title: Text(
                                                // "${routeData[vehicles[index].vehicle.trip.routeId.toString()]!["route_short_name"].toString()} Line heading to ${tripData[tripData.indexWhere((element) => element["trip_id"] == vehicles[index].vehicle.trip.tripId)]["trip_headsign"].toString()} ${status[vehicles[index].vehicle.currentStatus.value].toUpperCase()} ${stopData[vehicles[index].vehicle.stopId]!["stop_name"]}"),

                                                "${tripData[tripData.indexWhere((element) => element["trip_id"] == vehicles[index].vehicle.trip.tripId)]["trip_headsign"].toString()} ${status[vehicles[index].vehicle.currentStatus.value].toUpperCase()} ${stopData[vehicles[index].vehicle.stopId]!["stop_name"]}"),
                                            //the current location of the selected train/bus
                                            trailing: IconButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pushReplacement(
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      MapView(
                                                                        lat: vehicles[index]
                                                                            .vehicle
                                                                            .position
                                                                            .latitude,
                                                                        long: vehicles[index]
                                                                            .vehicle
                                                                            .position
                                                                            .longitude,
                                                                        line: routeData[vehicles[index].vehicle.trip.routeId.toString()] ==
                                                                                null
                                                                            ? "line unknown"
                                                                            : routeData[vehicles[index].vehicle.trip.routeId.toString()]!["route_short_name"].toString(),
                                                                        vehicleId: vehicles[index]
                                                                            .vehicle
                                                                            .vehicle
                                                                            .id,
                                                                        status: vehicles[index]
                                                                            .vehicle
                                                                            .currentStatus
                                                                            .toString(),
                                                                        route: routeData[vehicles[index].vehicle.trip.routeId.toString()] ==
                                                                                null
                                                                            ? "route name unknown"
                                                                            : routeData[vehicles[index].vehicle.trip.routeId.toString()]!["route_long_name"].toString(),
                                                                      )));
                                                },
                                                icon: const Icon(
                                                    Icons.place_outlined)),
                                            //route direction information & current status of movement
                                            subtitle: Text(
                                                "Status update on ${DateFormat.yMMMMd('en_US').add_jm().format(DateTime.fromMillisecondsSinceEpoch(vehicles[index].vehicle.timestamp.toInt() * 1000))}"),
                                          ),
                                        ),
                                      ),
                                      OutlinedButton(
                                          onPressed: () {
                                            if (stopSelected == "") {
                                              setState(() {
                                                if (stopData[vehicles[index]
                                                        .vehicle
                                                        .stopId]!
                                                    .isEmpty) {
                                                  setState(() {
                                                    stopSelected = "empty";
                                                  });
                                                } else {
                                                  stopSelected = stopData[
                                                              vehicles[index]
                                                                  .vehicle
                                                                  .stopId]![
                                                          "stop_name"]
                                                      .toString();
                                                }
                                              });
                                            } else {
                                              setState(() {
                                                stopSelected = "";
                                              });
                                            }
                                          },
                                          child: stopSelected ==
                                                  stopData[vehicles[index]
                                                          .vehicle
                                                          .stopId]!["stop_name"]
                                                      .toString()
                                              ? const Text(
                                                  "Hide Stop Information")
                                              : const Text(
                                                  "Show Stop Information")),
                                      stopSelected ==
                                              stopData[vehicles[index]
                                                      .vehicle
                                                      .stopId]!["stop_name"]
                                                  .toString()
                                          ? Container(
                                              child: ListView.builder(
                                                  shrinkWrap: true,
                                                  // physics:
                                                  //     const AlwaysScrollableScrollPhysics(),
                                                  itemCount: stops.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    List<FeedEntity>
                                                        thisAlertsList = [];

                                                    for (var i = 0;
                                                        i <= alerts.length - 1;
                                                        i++) {
                                                      var informedEntities =
                                                          alerts[i]
                                                              .alert
                                                              .informedEntity;
                                                      for (var entity
                                                          in informedEntities) {
                                                        if (entity.stopId ==
                                                            stops[index]
                                                                .stopId) {
                                                          thisAlertsList
                                                              .add(alerts[i]);

                                                          print(thisAlertsList
                                                              .toString());
                                                        }
                                                      }
                                                    }

                                                    return ListTile(
                                                      isThreeLine: true,
                                                      leading: IconButton(
                                                        onPressed: () {
                                                          //popup for station list here
                                                          showDialog(
                                                              context: context,
                                                              builder: (BuildContext
                                                                      context) =>
                                                                  _buildPopupDialog(
                                                                      context,
                                                                      thisAlertsList));
                                                        },
                                                        icon: thisAlertsList
                                                                .isNotEmpty
                                                            ? const Icon(
                                                                Icons
                                                                    .railway_alert,
                                                                color:
                                                                    Colors.red,
                                                                shadows: <
                                                                    Shadow>[
                                                                  Shadow(
                                                                      color: Colors
                                                                          .black45,
                                                                      blurRadius:
                                                                          20.0,
                                                                      offset:
                                                                          Offset(
                                                                              0,
                                                                              2.0))
                                                                ],
                                                              )
                                                            : const Icon(null),
                                                      ),
                                                      title: Center(
                                                        child: Text(stopData[
                                                                    stops[index]
                                                                        .stopId]![
                                                                "stop_name"]
                                                            .toString()),
                                                      ),
                                                      subtitle: Column(
                                                        children: [
                                                          Text(
                                                              "Arrives at ${DateFormat.yMMMMd('en_US').add_jm().format(DateTime.fromMillisecondsSinceEpoch(stops[index].arrival.time.toInt() * 1000))}"),
                                                          Text(
                                                              "Departs at ${DateFormat.yMMMMd('en_US').add_jm().format(DateTime.fromMillisecondsSinceEpoch(stops[index].departure.time.toInt() * 1000))}")
                                                        ],
                                                      ),
                                                      trailing: const Icon(Icons
                                                          .info_outline_rounded),
                                                    );
                                                  }))
                                          : const SizedBox(),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox();
              }),
        ),
      ),
    );
  }
}
