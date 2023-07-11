import 'package:flutter/material.dart';
import 'package:gtfs_realtime_bindings/gtfs_realtime_bindings.dart';
import 'package:intl/intl.dart';

class AlertPopup extends StatefulWidget {
  const AlertPopup({super.key, required this.alerts});
  final List<FeedEntity> alerts;

  @override
  State<AlertPopup> createState() => _AlertPopupState();
}

class _AlertPopupState extends State<AlertPopup> {
  late List<FeedEntity> alertList;

  @override
  void initState() {
    alertList = widget.alerts;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Service Alerts'),
      content: alertList.isNotEmpty
          ? SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: alertList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      isThreeLine: true,
                      title: Column(
                        children: [
                          Text(alertList[index]
                              .alert
                              .descriptionText
                              .translation[0]
                              .text
                              .toString()),
                          const SizedBox(
                            height: 10,
                            width: 100,
                          ),
                          alertList[index].alert.activePeriod[0].start.toInt() >
                                  0
                              ? Text(
                                  "Starting ${DateFormat.yMMMMd('en_US').format(DateTime.fromMillisecondsSinceEpoch(alertList[index].alert.activePeriod[0].start.toInt() * 1000))}")
                              : const SizedBox(),
                          const SizedBox(
                            height: 10,
                            width: 100,
                          ),
                          alertList[index].alert.activePeriod[0].end.toInt() > 0
                              ? Text(
                                  "Ending ${DateFormat.yMMMMd('en_US').format(DateTime.fromMillisecondsSinceEpoch(alertList[index].alert.activePeriod[0].end.toInt() * 1000))}")
                              : const SizedBox(),
                        ],
                      ),
                      subtitle: Text(alertList[index]
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
}
