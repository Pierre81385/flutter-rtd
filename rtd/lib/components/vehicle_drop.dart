import 'package:flutter/material.dart';
import 'color_hex_argb.dart';

class VehicleSelection extends StatefulWidget {
  const VehicleSelection({required this.onChange, super.key});
  final ValueChanged<String> onChange;

  @override
  State<VehicleSelection> createState() => _VehicleSelectionState();
}

class _VehicleSelectionState extends State<VehicleSelection> {
  late TextStyle headSignStyle;

  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(
        value: "select",
        child: Text(
          'SELECT A LINE...',
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
      ),
      DropdownMenuItem(
          value: "A",
          child: Text(
            "A - Union Station to Denver Airport",
            style: TextStyle(
                color: hexToArgbColor("57C1E9"), fontWeight: FontWeight.bold),
          )),
      DropdownMenuItem(
          value: "B",
          child: Text(
            "B - Union Station to Westminster",
            style: TextStyle(
                color: hexToArgbColor("4E9D2D"), fontWeight: FontWeight.bold),
          )),
      DropdownMenuItem(
          value: "D",
          child: Text(
            "D - 18th & California to Littleton - Mineral",
            style: TextStyle(
                color: hexToArgbColor("008348"), fontWeight: FontWeight.bold),
          )),
      DropdownMenuItem(
        value: "E",
        child: Text(
          "E - Union Station to RidgeGate Parkway",
          style: TextStyle(
              color: hexToArgbColor("552683"), fontWeight: FontWeight.bold),
        ),
      ),
      DropdownMenuItem(
          value: "G",
          child: Text(
            "G - Union Station to Wheat Ridge Ward",
            style: TextStyle(
                color: hexToArgbColor("F6B221"), fontWeight: FontWeight.bold),
          )),
      DropdownMenuItem(
          value: "H",
          child: Text(
            "H - 18th & California to Florida Station",
            style: TextStyle(
                color: hexToArgbColor("0075BE"), fontWeight: FontWeight.bold),
          )),
      DropdownMenuItem(
          value: "L",
          child: Text(
            "L - 30th & Downing to 16th & Stout",
            style: TextStyle(
                color: hexToArgbColor("FFCE00"), fontWeight: FontWeight.bold),
          )),
      DropdownMenuItem(
          value: "N",
          child: Text(
            "N - Union Station to Eastlake",
            style: TextStyle(
                color: hexToArgbColor("9F26B5"), fontWeight: FontWeight.bold),
          )),
      DropdownMenuItem(
          value: "R",
          child: Text(
            "R - Peoria Station to RidgeGate Parkway",
            style: TextStyle(
                color: hexToArgbColor("C4D600"), fontWeight: FontWeight.bold),
          )),
      DropdownMenuItem(
          value: "W",
          child: Text(
            "W - Union Station to JeffCo - Golden",
            style: TextStyle(
                color: hexToArgbColor("009DAA"), fontWeight: FontWeight.bold),
          )),
    ];
    return menuItems;
  }

  late String selectedValue;

  @override
  void initState() {
    selectedValue = "select";
    headSignStyle =
        const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
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
                                                    ? hexToArgbColor("C4D600")
                                                    : selectedValue == "W"
                                                        ? hexToArgbColor(
                                                            "009DAA")
                                                        : Colors.black,
              ),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              dropdownColor: Colors.black,
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
                                                        ? hexToArgbColor(
                                                            "009DAA")
                                                        : Colors.amber,
              ),
              onChanged: (value) {
                setState(() {
                  selectedValue = value!;
                });
                widget.onChange(value!);
                print(value);
                print(selectedValue);
              },
            ),
          ),
        ),
      ),
    );
  }
}
