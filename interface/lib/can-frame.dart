import 'package:can_interface/theme.dart';
import 'package:flutter/material.dart';

class CanFrame extends StatefulWidget {
  final int? uuid;
  final bool prioritySel;
  final bool powerSel;
  final bool motorSel;
  final bool peripheralSel;
  const CanFrame({
    required this.uuid,
    required this.prioritySel,
    required this.powerSel,
    required this.motorSel,
    required this.peripheralSel,
    super.key,
  });

  @override
  State<CanFrame> createState() => _CanFrameState();
}

class _CanFrameState extends State<CanFrame> {
  String cmdText = "";
  String dlcText = "";

  @override
  Widget build(BuildContext context) {
    // represent segmented button fields falues as "1" if selected
    final String priority = (widget.prioritySel) ? "1" : "0";
    final String power = (widget.powerSel) ? "1" : "0";
    final String motor = (widget.motorSel) ? "1" : "0";
    final String peripheral = (widget.peripheralSel) ? "1" : "0";

    // UUID: form binary string, verify is valid hex. <=127
    int? uuid = widget.uuid;
    final bool uuidValid = uuid != null && uuid <= 127;
    final String uuidStr = (uuidValid)
        ? uuid.toRadixString(2).padLeft(7, "0")
        : "XXXXXXX";

    // ADDRESS
    String address = priority + uuidStr + power + motor + peripheral;

    // COMMAND ID: form binary string, verify is valid hex.
    final int? cmdAsInt = int.tryParse(cmdText, radix: 16);
    final bool cmdValid = cmdAsInt != null;
    final String cmdStr = (cmdValid)
        ? cmdAsInt.toRadixString(2).toUpperCase().padLeft(8, "0")
        : "XXXXXXXX";

    // DLC: form DLC string, verify is <=8 and is valid decimal
    final int? dlcAsInt = int.tryParse(dlcText, radix: 10);
    final bool dlcValid = dlcAsInt != null && dlcAsInt <= 8;
    final String dlcStr = (dlcValid)
        ? dlcAsInt.toRadixString(2).padLeft(4, "0")
        : "XXXX";

    // generate error list
    List<String> errorList = [];
    if (!uuidValid) {
      errorList.add("UUID: Invalid Hex <0x80");
    }
    if (!cmdValid) {
      errorList.add("CMD: Invalid Hex <0x80");
    }
    if (!dlcValid) {
      errorList.add("DLC: Invalid Base-10 ≤8");
    }

    // form full packet as string
    String generatedPacket = "$address $dlcStr $cmdStr 1110001 [B0 B1 B2 B3 B4 B5]";
    print("gen packet: $generatedPacket");

    return Container(
      decoration: BoxDecoration(
        color: darkColorScheme.surface,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      padding: EdgeInsets.only(left: 18, right: 18, top: 12, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Frame",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: darkColorScheme.onPrimary,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          generatedPacket,
                          style: TextStyle(
                            fontFamily: "JetBrainsMono",
                            color: darkColorScheme.onSecondary,
                            fontSize: 15.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: SizedBox(
                              width: 90,
                              child: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    cmdText = value;
                                  });
                                },
                                style: TextStyle(
                                  color: darkColorScheme.onSecondary,
                                ),
                                decoration: InputDecoration(
                                  labelText: "CMD",
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
                                onChanged: (value) {
                                  setState(() {
                                    dlcText = value;
                                  });
                                },
                                style: TextStyle(
                                  color: darkColorScheme.onSecondary,
                                ),
                                decoration: InputDecoration(
                                  labelText: "DLC",
                                  labelStyle: TextStyle(
                                    color: darkColorScheme.onSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: SizedBox(
                              width: 90,
                              child: TextField(
                                style: TextStyle(
                                  color: darkColorScheme.onSecondary,
                                ),
                                decoration: InputDecoration(
                                  labelText: "B0",
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
                                style: TextStyle(
                                  color: darkColorScheme.onSecondary,
                                ),
                                decoration: InputDecoration(
                                  labelText: "B1",
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
                                style: TextStyle(
                                  color: darkColorScheme.onSecondary,
                                ),
                                decoration: InputDecoration(
                                  labelText: "B2",
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
                                style: TextStyle(
                                  color: darkColorScheme.onSecondary,
                                ),
                                decoration: InputDecoration(
                                  labelText: "B3",
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
                                style: TextStyle(
                                  color: darkColorScheme.onSecondary,
                                ),
                                decoration: InputDecoration(
                                  labelText: "B4",
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
                                style: TextStyle(
                                  color: darkColorScheme.onSecondary,
                                ),
                                decoration: InputDecoration(
                                  labelText: "B5",
                                  labelStyle: TextStyle(
                                    color: darkColorScheme.onSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: (errorList.isEmpty
                // no errors, so allow user to send packet
                ? IconButton.filled(
                    onPressed: () {
                      // TODO: send packet over usb
                      print("SEND pressed");
                    },
                    icon: Icon(Icons.arrow_upward_rounded),
                    color: darkColorScheme.onSecondary,
                    tooltip: "Send packet",
                  )
                // there is an input error, so show dummy button with message
                : IconButton.filled(
                    onPressed: null,
                    icon: Icon(Icons.error_outline_rounded),
                    disabledColor: darkColorScheme.onError,
                    tooltip: errorList.join("; "),
                  )),
          ),
        ],
      ),
    );
  }
}
