import 'package:can_interface/theme.dart';
import 'package:flutter/material.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.6,
          child: SizedBox(
            height: 55,
            child: Card.filled(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(55 / 2),
              ),
              color: darkColorScheme.primary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Text(
                      "CAN Tester",
                      style: TextStyle(
                        color: Color.fromRGBO(227, 217, 247, 1),
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 4,
                        ),
                        child: IconButton(
                          color: darkColorScheme.onSecondary,
                          onPressed: () {},
                          icon: Icon(Icons.bug_report_outlined),
                          tooltip: "Not implemented: Issues",
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 4,
                        ),
                        child: IconButton(
                          color: darkColorScheme.onSecondary,
                          onPressed: () {},
                          icon: Icon(Icons.help_outline_rounded),
                          tooltip: "Not implemented: Help",
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 4,
                        ),
                        child: IconButton(
                          color: darkColorScheme.onSecondary,
                          onPressed: () {},
                          icon: Icon(Icons.add_rounded),
                          tooltip: "Not implemented: Add another device",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Terminal extends StatelessWidget {
  const Terminal({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 477,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Container(
              height: 106,
              decoration: BoxDecoration(
                color: darkColorScheme.secondary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Center(child: Text("Filters")),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: darkColorScheme.secondary,
                ),
                child: Center(child: Text("Output")),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 8,
              right: 8,
              bottom: 8,
              top: 6,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: darkColorScheme.secondary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 8),
                    child: Text(
                      "Send: ",
                      style: TextStyle(
                        fontSize: 18,
                        color: darkColorScheme.onSecondary,
                      ),
                    ),
                  ),
                  Expanded(child: TextField()),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: IconButton.filled(
                      onPressed: () {},
                      icon: Icon(Icons.arrow_upward_rounded),
                      color: darkColorScheme.onSecondary,
                      tooltip: "Send packet over USB to CAN bus",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum Options { priority, power, motor, peripheral }

class DeviceCard extends StatefulWidget {
  DeviceCard({super.key});

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  Set<Options> selection = <Options>{};

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 60, right: 60, top: 60),
      child: Container(
        decoration: BoxDecoration(
          color: darkColorScheme.secondary,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    "Device",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: darkColorScheme.onPrimary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 75,
                  child: TextField(
                    style: TextStyle(color: darkColorScheme.onSecondary),
                    decoration: InputDecoration(
                      labelText: "UUID (7)",
                      labelStyle: TextStyle(color: darkColorScheme.onSecondary),
                    ),
                  ),
                ),
                SegmentedButton(
                  segments: [
                    ButtonSegment(
                      value: Options.priority,
                      label: Text(
                        style: TextStyle(color: darkColorScheme.onSecondary),
                        "Priority",
                      ),
                    ),
                    ButtonSegment(
                      value: Options.power,
                      label: Text(
                        style: TextStyle(color: darkColorScheme.onSecondary),
                        "Power",
                      ),
                    ),
                    ButtonSegment(
                      value: Options.motor,
                      label: Text(
                        style: TextStyle(color: darkColorScheme.onSecondary),
                        "Motor",
                      ),
                    ),
                    ButtonSegment(
                      value: Options.peripheral,
                      label: Text(
                        style: TextStyle(color: darkColorScheme.onSecondary),
                        "Peripheral",
                      ),
                    ),
                  ],
                  selected: selection,
                  onSelectionChanged: (Set<Options> newSelection) {
                    setState(() {
                      selection = newSelection;
                    });
                  },
                  multiSelectionEnabled: true,
                  emptySelectionAllowed: true,
                  style: SegmentedButton.styleFrom(
                    side: BorderSide(color: darkColorScheme.onSecondary),
                    selectedBackgroundColor: darkColorScheme.primary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: IconButton.filled(
                    onPressed: () {},
                    icon: Icon(Icons.close_rounded),
                    tooltip: "Not implemented: Remove this device entry",
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, bottom: 12),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: SizedBox(
                      width: 90,
                      child: TextField(
                        style: TextStyle(color: darkColorScheme.onSecondary),
                        decoration: InputDecoration(
                          labelText: "Byte 0",
                          labelStyle: TextStyle(
                            color: darkColorScheme.onSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: SizedBox(
                      width: 90,
                      child: TextField(
                        style: TextStyle(color: darkColorScheme.onSecondary),
                        decoration: InputDecoration(
                          labelText: "Byte 1",
                          labelStyle: TextStyle(
                            color: darkColorScheme.onSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: SizedBox(
                      width: 90,
                      child: TextField(
                        style: TextStyle(color: darkColorScheme.onSecondary),
                        decoration: InputDecoration(
                          labelText: "Byte 2",
                          labelStyle: TextStyle(
                            color: darkColorScheme.onSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: SizedBox(
                      width: 90,
                      child: TextField(
                        style: TextStyle(color: darkColorScheme.onSecondary),
                        decoration: InputDecoration(
                          labelText: "Byte 3",
                          labelStyle: TextStyle(
                            color: darkColorScheme.onSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: SizedBox(
                      width: 90,
                      child: TextField(
                        style: TextStyle(color: darkColorScheme.onSecondary),
                        decoration: InputDecoration(
                          labelText: "Byte 4",
                          labelStyle: TextStyle(
                            color: darkColorScheme.onSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: SizedBox(
                      width: 90,
                      child: TextField(
                        style: TextStyle(color: darkColorScheme.onSecondary),
                        decoration: InputDecoration(
                          labelText: "Byte 5",
                          labelStyle: TextStyle(
                            color: darkColorScheme.onSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: SizedBox(
                      width: 90,
                      child: TextField(
                        style: TextStyle(color: darkColorScheme.onSecondary),
                        decoration: InputDecoration(
                          labelText: "Byte 6",
                          labelStyle: TextStyle(
                            color: darkColorScheme.onSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: SizedBox(
                      width: 90,
                      child: TextField(
                        style: TextStyle(color: darkColorScheme.onSecondary),
                        decoration: InputDecoration(
                          labelText: "Byte 7",
                          labelStyle: TextStyle(
                            color: darkColorScheme.onSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: IconButton.filled(
                      onPressed: () {},
                      icon: Icon(Icons.arrow_upward_rounded),
                      color: darkColorScheme.onSecondary,
                      tooltip: "Send packet over USB to CAN bus",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  static const double mainMargin = 9;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(20, 18, 23, 1),
      body: Column(
        children: [
          TitleBar(),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: ListView(children: [DeviceCard()])),
                      FloatingActionButton.extended(
                        onPressed: () {},
                        tooltip: "Send E-STOP",
                        backgroundColor: darkColorScheme.primary,
                        foregroundColor: darkColorScheme.onSecondary,
                        icon: Icon(Icons.cancel_outlined),
                        label: Text("E-STOP"),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 20,
                        ),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            "Alpha 0.1.0 by Rishi Roy",
                            style: TextStyle(
                              color: darkColorScheme.onSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Terminal(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
