import 'package:flutter/material.dart';
import 'package:gtfs_realtime_bindings/gtfs_realtime_bindings.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rtd/components/alert_pop.dart';
import 'package:rtd/components/info_pop.dart';
import 'package:rtd/data_sets/stop_time.dart';
import 'package:rtd/gtfs/map.dart';
import '../data_sets/route_data.dart';
import '../data_sets/stop_data.dart';
import '../data_sets/trip_data.dart';
import 'dart:async';
import 'package:rtd/components/color_hex_argb.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/src/models/position.dart'
    as user_position;

class RTDFeed extends StatefulWidget {
  const RTDFeed({required this.lineSelected, super.key});
  final String lineSelected;

  @override
  State<RTDFeed> createState() => _RTDFeedState();
}

class _RTDFeedState extends State<RTDFeed> {
  late List<FeedEntity> _feedAlerts = [];
  late List<FeedEntity> _feedTrips = [];
  late List<FeedEntity> vehicles = [];
  late GlobalKey<ScaffoldState> _scaffoldKey;
  late List<Map<String, Object>> _trainStops = [];
  late bool alertsFinished = false;
  late bool tripsFinished = false;
  late bool vehiclesFinished = false;
  late String stopSelected;
  late bool stopScroll;
  late Timer updateTimer;
  late Timer countdownTimer;
  final time = const Duration(seconds: 120);
  final countDown = const Duration(seconds: 1);
  final status = ["incoming at", "stopped at", "in transit to"];
  final snack = const SnackBar(
    content: Text('Data Refreshed'),
  );
  int nextUpdate = 120;
  late user_position.Position _userPosition;
  late double _distance;
  List routeIds = [
    "A",
    "113B",
    "101D",
    "101E",
    "113G",
    "101H",
    "109L",
    "117N",
    "107R",
    "103W"
  ];

  //gtfs-rt auto-updater
  void StartTimer() {
    countdownTimer = Timer.periodic(countDown, (Timer timer) {
      if (nextUpdate == 0) {
        setState(() {
          nextUpdate = 120;
        });
      } else {
        setState(() {
          nextUpdate--;
        });
      }
    });

    updateTimer = Timer.periodic(time, (Timer timer) {
      //print("data update requested");
      AlertFeed();
      VehicaleFeed();
      TripFeed();
      _getCurrentPosition();
    });
  }

  //real time trip alerts data
  void AlertFeed() async {
    final url = Uri.parse('https://www.rtd-denver.com/files/gtfs-rt/Alerts.pb');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final feedMessage = FeedMessage.fromBuffer(response.bodyBytes);

      setState(() {
        _feedAlerts = feedMessage.entity;
        alertsFinished = true;
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  //real time trip data
  void TripFeed() async {
    final url =
        Uri.parse('https://www.rtd-denver.com/files/gtfs-rt/TripUpdate.pb');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final feedMessage = FeedMessage.fromBuffer(response.bodyBytes);

      setState(() {
        _feedTrips = feedMessage.entity;
        tripsFinished = true;
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  //real time vehicle data
  void VehicaleFeed() async {
    final url = Uri.parse(
        'https://www.rtd-denver.com/files/gtfs-rt/VehiclePosition.pb');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final feedMessage = FeedMessage.fromBuffer(response.bodyBytes);

      setState(() {
        vehicles = feedMessage.entity;
        vehiclesFinished = true;
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;

    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((user_position.Position position) {
      print('getting user location: ' + position.toString());
      setState(() {
        _userPosition = position;
      });
    }).catchError((e) {
      print(e);
    });
  }

  @override
  void initState() {
    AlertFeed();
    VehicaleFeed();
    TripFeed();
    _userPosition =
        user_position.Position.fromMap({'latitude': 0.0, 'longitude': -0.0});
    _distance = 0;
    _scaffoldKey = GlobalKey();
    stopSelected = "";
    stopScroll = false;
    StartTimer();
    super.initState();
  }

  @override
  void dispose() {
    countdownTimer.cancel(); //cancel the periodic task
    countdownTimer;
    updateTimer.cancel();
    updateTimer; //clear the timer variable
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      key: _scaffoldKey,
      body: RefreshIndicator(
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
              //print("updating real time feed data!");

              // showing snackbar
              ScaffoldMessenger.of(context).showSnackBar(snack);
            },
          );
        },
        child: ListView.builder(
            physics: stopScroll == false
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            itemCount: vehicles.length,
            itemBuilder: (BuildContext context, int index) {
              List<TripUpdate_StopTimeUpdate> stops = [];
              //finding all trips in tripUpdate RT FEED that match selected vehicle tripId
              int tripIndex = _feedTrips.indexWhere((element) =>
                  element.tripUpdate.trip.tripId ==
                  vehicles[index].vehicle.trip.tripId);
              if (tripIndex == -1) {
                //print('gather information');
              } else {
                for (var i = 0;
                    i <= _feedTrips[tripIndex].tripUpdate.stopTimeUpdate.length;
                    i++) {
                  //listing all of the stops remaining for this tripId
                  stops =
                      _feedTrips[tripIndex].tripUpdate.stopTimeUpdate.toList();
                }
              }

              if (_userPosition.latitude == 0 && _userPosition.longitude == 0) {
                _getCurrentPosition();
              }

              //get route data of the selected train/bus
              return routeData[
                          vehicles[index].vehicle.trip.routeId.toString()] ==
                      null
                  ? const SizedBox()
                  : widget.lineSelected == "select"
                      ? const SizedBox()
                      : routeData[vehicles[index]
                                      .vehicle
                                      .trip
                                      .routeId
                                      .toString()]!["route_short_name"]
                                  .toString() ==
                              widget.lineSelected
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  border: Border.all(
                                      color: hexToArgbColor(routeData[vehicles[
                                                      index]
                                                  .vehicle
                                                  .trip
                                                  .routeId
                                                  .toString()]!["route_color"]
                                              .toString())
                                          .withOpacity(1.0)),
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
                                          color: hexToArgbColor(routeData[
                                                          vehicles[index]
                                                              .vehicle
                                                              .trip
                                                              .routeId
                                                              .toString()]![
                                                      "route_color"]
                                                  .toString())
                                              .withOpacity(1.0),
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10)),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 5,
                                              blurRadius: 7,
                                              offset: const Offset(0,
                                                  3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: ListTile(
                                          isThreeLine: true,
                                          leading: Text(
                                            "#${vehicles[index].vehicle.vehicle.label.toString()}",
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          //descriptive name of the route
                                          title: Text(
                                              textAlign: TextAlign.center,
                                              // "${routeData[vehicles[index].vehicle.trip.routeId.toString()]!["route_short_name"].toString()} Line heading to ${tripData[tripData.indexWhere((element) => element["trip_id"] == vehicles[index].vehicle.trip.tripId)]["trip_headsign"].toString()} ${status[vehicles[index].vehicle.currentStatus.value].toUpperCase()} ${stopData[vehicles[index].vehicle.stopId]!["stop_name"]}"),
                                              style: const TextStyle(
                                                  color: Colors.white),
                                              "${tripData[tripData.indexWhere((element) => element["trip_id"] == vehicles[index].vehicle.trip.tripId)]["trip_headsign"].toString()} train ${status[vehicles[index].vehicle.currentStatus.value].toString()} ${stopData[vehicles[index].vehicle.stopId]!["stop_name"]}"),
                                          //the current location of the selected train/bus
                                          trailing: IconButton(
                                              color: Colors.white,
                                              onPressed: () {
                                                Navigator.of(context).pushReplacement(MaterialPageRoute(
                                                    builder: (context) => MapView(
                                                        stops: stops,
                                                        lat: vehicles[index]
                                                            .vehicle
                                                            .position
                                                            .latitude,
                                                        long: vehicles[index]
                                                            .vehicle
                                                            .position
                                                            .longitude,
                                                        line: routeData[vehicles[index].vehicle.trip.routeId.toString()] == null
                                                            ? "line unknown"
                                                            : routeData[vehicles[index].vehicle.trip.routeId.toString()]![
                                                                    "route_short_name"]
                                                                .toString(),
                                                        vehicleId:
                                                            vehicles[index]
                                                                .vehicle
                                                                .vehicle
                                                                .id,
                                                        status: vehicles[index]
                                                            .vehicle
                                                            .currentStatus
                                                            .toString(),
                                                        route: vehicles[index]
                                                            .vehicle
                                                            .trip
                                                            .routeId
                                                            .toString())));
                                              },
                                              icon: const Icon(
                                                  Icons.place_outlined)),
                                          //route direction information & current status of movement
                                          subtitle: Text(
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                              "Status update on ${DateFormat.yMMMMd('en_US').add_jm().format(DateTime.fromMillisecondsSinceEpoch(vehicles[index].vehicle.timestamp.toInt() * 1000))}.  Next update: ${nextUpdate.toString()} seconds."),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: stopSelected ==
                                              stopData[vehicles[index]
                                                      .vehicle
                                                      .stopId]!["stop_name"]
                                                  .toString()
                                          ? const Icon(Icons.keyboard_arrow_up)
                                          : const Icon(
                                              Icons.keyboard_arrow_down),
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
                                                          .stopId]!["stop_name"]
                                                  .toString();
                                            }
                                          });
                                        } else {
                                          setState(() {
                                            stopSelected = "";
                                          });
                                        }
                                      },
                                    ),
                                    stopSelected ==
                                            stopData[vehicles[index]
                                                    .vehicle
                                                    .stopId]!["stop_name"]
                                                .toString()
                                        ? ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: stops.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              List<FeedEntity> thisAlertsList =
                                                  [];

                                              for (var i = 0;
                                                  i <= _feedAlerts.length - 1;
                                                  i++) {
                                                var informedEntities =
                                                    _feedAlerts[i]
                                                        .alert
                                                        .informedEntity;
                                                for (var entity
                                                    in informedEntities) {
                                                  if (entity.stopId ==
                                                      stops[index].stopId) {
                                                    thisAlertsList
                                                        .add(_feedAlerts[i]);
                                                  }
                                                }
                                              }

                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    10),
                                                            topRight:
                                                                Radius.circular(
                                                                    10),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10)),
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
                                                    leading: IconButton(
                                                      onPressed: () {
                                                        //popup for station list here
                                                        showDialog(
                                                            context: context,
                                                            builder: (BuildContext
                                                                    context) =>
                                                                AlertPopup(
                                                                    alerts:
                                                                        thisAlertsList));
                                                      },
                                                      icon: thisAlertsList
                                                              .isNotEmpty
                                                          ? const Icon(
                                                              Icons
                                                                  .railway_alert,
                                                              color: Colors.red,
                                                              shadows: <Shadow>[
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
                                                            "Expected arrival: ${DateFormat.yMMMMd('en_US').add_jm().format(DateTime.fromMillisecondsSinceEpoch(stops[index].arrival.time.toInt() * 1000))}"),
                                                        Text(
                                                            "Expected departure: ${DateFormat.yMMMMd('en_US').add_jm().format(DateTime.fromMillisecondsSinceEpoch(stops[index].departure.time.toInt() * 1000))}")
                                                      ],
                                                    ),
                                                    trailing: IconButton(
                                                        onPressed: () {
                                                          //popup for station list here
                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) => InfoPopup(
                                                                title: stopData[
                                                                            stops[index].stopId]![
                                                                        "stop_name"]
                                                                    .toString(),
                                                                content: Geolocator.distanceBetween(
                                                                    _userPosition
                                                                        .latitude,
                                                                    _userPosition
                                                                        .longitude,
                                                                    stopData[stops[index].stopId]![
                                                                            "stop_lat"]
                                                                        as double,
                                                                    stopData[stops[index].stopId]![
                                                                            "stop_lon"]
                                                                        as double)),
                                                          );
                                                        },
                                                        icon: const Icon(Icons
                                                            .transfer_within_a_station_outlined)),
                                                  ),
                                                ),
                                              );
                                            })
                                        : const SizedBox(),
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox();
            }),
      ),
    );
  }
}
