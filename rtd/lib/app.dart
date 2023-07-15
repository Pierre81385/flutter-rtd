import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'components/vehicle_drop.dart';
import 'gtfs/feed.dart';

class RTDApp extends StatefulWidget {
  const RTDApp({super.key});

  @override
  State<RTDApp> createState() => _RTDAppState();
}

class _RTDAppState extends State<RTDApp> {
  late String _lineSelected = "select";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Where\'s my train?'),
      // ),
      body: Container(
        // decoration: const BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage("lib/assets/background.jpeg"),
        //     fit: BoxFit.cover,
        //   ),
        // ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: VehicleSelection(onChange: (value) {
                    setState(() {
                      _lineSelected = value;
                    });
                  }),
                ),
              ),
              Expanded(
                  child: RTDFeed(
                lineSelected: _lineSelected,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
