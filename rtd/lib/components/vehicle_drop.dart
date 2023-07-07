import 'package:flutter/material.dart';
import 'color_hex_argb.dart';

class VehicleSelection extends StatefulWidget {
  const VehicleSelection({required this.onChange, super.key});
  final ValueChanged<String> onChange;

  @override
  State<VehicleSelection> createState() => _VehicleSelectionState();
}

class _VehicleSelectionState extends State<VehicleSelection> {
  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "select", child: Text('Select a Line')),
      const DropdownMenuItem(
          value: "A", child: Text("A - Union Station to Denver Airport")),
      const DropdownMenuItem(
          value: "B", child: Text("B - Union Station to Westminster")),
      const DropdownMenuItem(
          value: "D",
          child: Text("D - 18th & California to Littleton - Mineral")),
      const DropdownMenuItem(
          value: "E", child: Text("E - Union Station to RidgeGate Parkway")),
      const DropdownMenuItem(
          value: "G", child: Text("G - Union Station to Wheat Ridge Ward")),
      const DropdownMenuItem(
          value: "H", child: Text("H - 18th & California to Florida Station")),
      const DropdownMenuItem(
          value: "L", child: Text("L - 30th & Downing to 16th & Stout")),
      const DropdownMenuItem(
          value: "N", child: Text("N - Union Station to Eastlake")),
      const DropdownMenuItem(
          value: "R", child: Text("R - Peoria Station to RidgeGate Parkway")),
      const DropdownMenuItem(
          value: "W", child: Text("W - Union Station to JeffCo - Golden")),
    ];
    return menuItems;
  }

  late String selectedValue;

  @override
  void initState() {
    selectedValue = "select";

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: InputDecorator(
          decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: selectedValue == "A"
                        ? hexToArgbColor("57C1E9")
                        : selectedValue == "B"
                            ? hexToArgbColor("4E9D2D")
                            : selectedValue == "D"
                                ? hexToArgbColor("008348")
                                : selectedValue == "E"
                                    ? hexToArgbColor("552683")
                                    : selectedValue == "G"
                                        ? hexToArgbColor("F6B221")
                                        : selectedValue == "H"
                                            ? hexToArgbColor("0075BE")
                                            : selectedValue == "L"
                                                ? hexToArgbColor("FFCE00")
                                                : selectedValue == "N"
                                                    ? hexToArgbColor("9F26B5")
                                                    : selectedValue == "R"
                                                        ? hexToArgbColor(
                                                            "C4D600")
                                                        : selectedValue == "W"
                                                            ? hexToArgbColor(
                                                                "009DAA")
                                                            : Colors.black,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10)))),
          child: DropdownButton(
            isExpanded: true,
            value: selectedValue,
            items: dropdownItems,
            icon: Icon(
              Icons.train,
              color: selectedValue == "A"
                  ? hexToArgbColor("57C1E9")
                  : selectedValue == "B"
                      ? hexToArgbColor("4E9D2D")
                      : selectedValue == "D"
                          ? hexToArgbColor("008348")
                          : selectedValue == "E"
                              ? hexToArgbColor("552683")
                              : selectedValue == "G"
                                  ? hexToArgbColor("F6B221")
                                  : selectedValue == "H"
                                      ? hexToArgbColor("0075BE")
                                      : selectedValue == "L"
                                          ? hexToArgbColor("FFCE00")
                                          : selectedValue == "N"
                                              ? hexToArgbColor("9F26B5")
                                              : selectedValue == "R"
                                                  ? hexToArgbColor("C4D600")
                                                  : selectedValue == "W"
                                                      ? hexToArgbColor("009DAA")
                                                      : Colors.black,
            ),
            onChanged: (value) {
              setState(() {
                selectedValue = value!;
              });
              widget.onChange(value!);
              //print(value);
              //print(selectedValue);
            },
          ),
        ),
      ),
    );
  }
}
