import 'package:can_interface/can-frame.dart';
import 'package:can_interface/theme.dart';
import 'package:can_interface/title-bar.dart';
import 'package:flutter/material.dart';

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
  String uuidText = "";
  final canFrameKeys = <int>[0]; // initially have 1 CanFrame
  int nextCanFrameKey = 1;

  @override
  Widget build(BuildContext context) {
    final int? uuidInt = int.tryParse(uuidText, radix: 16);

    return Padding(
      padding: const EdgeInsets.only(left: 60, right: 60, top: 60),
      child: Container(
        decoration: BoxDecoration(
          color: darkColorScheme.secondary,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.only(top: 8),
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
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: darkColorScheme.onPrimary,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 95,
                        child: TextFormField(
                          onChanged: (value) {
                            setState(() {
                              uuidText = value;
                            });
                          },
                          style: TextStyle(color: darkColorScheme.onSecondary),
                          cursorColor: darkColorScheme.onSecondary,
                          decoration: InputDecoration(
                            isDense: true,
                            // label: Center(child: Text("UUID")),
                            hint: Text(
                              "UUID",
                              style: TextStyle(
                                color: darkColorScheme.onSecondary,
                                fontSize: 16,
                              ),
                            ),
                            prefix: Text(
                              "0x",
                              style: TextStyle(
                                color: darkColorScheme.onSecondary,
                                fontSize: 16.5,
                              ),
                            ),
                            labelStyle: TextStyle(
                              color: darkColorScheme.onSecondary,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(
                                color: darkColorScheme.onSecondary,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(
                                color: darkColorScheme.onPrimary,
                              ),
                            ),
                          ),
                          // textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SegmentedButton(
                      segments: [
                        ButtonSegment(
                          value: Options.priority,
                          label: Text(
                            style: TextStyle(
                              color: darkColorScheme.onSecondary,
                            ),
                            "Priority",
                          ),
                        ),
                        ButtonSegment(
                          value: Options.power,
                          label: Text(
                            style: TextStyle(
                              color: darkColorScheme.onSecondary,
                            ),
                            "Power",
                          ),
                        ),
                        ButtonSegment(
                          value: Options.motor,
                          label: Text(
                            style: TextStyle(
                              color: darkColorScheme.onSecondary,
                            ),
                            "Motor",
                          ),
                        ),
                        ButtonSegment(
                          value: Options.peripheral,
                          label: Text(
                            style: TextStyle(
                              color: darkColorScheme.onSecondary,
                            ),
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
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: IconButton.filled(
                        onPressed: () {
                          setState(() {
                            // add new CanFrame card key to list for re-render
                            nextCanFrameKey++; // increment key id
                            canFrameKeys.add(nextCanFrameKey);
                          });
                        },
                        icon: Icon(Icons.add_rounded),
                        color: darkColorScheme.onSecondary,
                        tooltip: "Add frame",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: IconButton.filled(
                        onPressed: () {},
                        icon: Icon(Icons.close_rounded),
                        tooltip: "Not implemented: Remove this device",
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 20,
                bottom: 20 - 8,
                left: 20,
                right: 20,
              ),
              child: Column(
                children: [
                  ...canFrameKeys.map(
                    (key) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: CanFrame(
                        key: ValueKey(key),
                        uuid: uuidInt,
                        prioritySel: selection.contains(Options.priority),
                        powerSel: selection.contains(Options.power),
                        motorSel: selection.contains(Options.motor),
                        peripheralSel: selection.contains(Options.peripheral),
                      ),
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TitleBar(),
          ),
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
                        tooltip: "Not implemented: Send E-STOP",
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
