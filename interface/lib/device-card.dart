import 'package:can_interface/can-frame.dart';
import 'package:can_interface/theme.dart';
import 'package:flutter/material.dart';

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
