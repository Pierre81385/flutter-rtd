import 'package:flutter/material.dart';

class InfoPopup extends StatefulWidget {
  const InfoPopup({super.key, required this.content, required this.title});
  final double content;
  final String title;
  @override
  State<InfoPopup> createState() => _InfoPopupState();
}

class _InfoPopupState extends State<InfoPopup> {
  late double infoContent;
  late String infoTitle;

  @override
  void initState() {
    infoContent = widget.content / 1609;
    infoTitle = widget.title;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(infoTitle + " is"),
      content: Text((infoContent).toStringAsFixed(2) + " miles from you."),
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
