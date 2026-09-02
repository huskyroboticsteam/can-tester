import 'dart:convert';

import 'package:can_interface/can.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:can_interface/theme.dart';
import 'package:mutex/mutex.dart';
import 'package:provider/provider.dart';

class PacketRowData {
  final CanPacket packet;
  final DateTime time;

  PacketRowData({required this.packet, required this.time});
}

// Singleton to hold list of received packets and update UI
class TerminalModel extends ChangeNotifier {
  final List<PacketRowData> _rows;
  final _mutex = Mutex();
  int _packetsDropped = 0;
  int _packetsReceived = 0;
  int _packetsSent = 0;

  // singleton instance
  static final TerminalModel _instance = TerminalModel._internal();

  // private constructor to initialize empty list
  TerminalModel._internal() : _rows = [];

  // factory constructor returns the same instance every time
  factory TerminalModel() => _instance;

  // Get list of received CAN packets
  List<PacketRowData> get rows => _rows;

  /// Appends a newly received CAN packet to the back of the model's list.
  /// Notifies listeners.
  Future<void> addRow(PacketRowData row) async {
    await _mutex.acquire();
    try {
      _rows.add(row);
    } finally {
      _mutex.release();
    }
    notifyListeners();
  }

  /// Remove all CAN packet entries. Notifies listeners.
  Future<void> clearAll() async {
    await _mutex.acquire();
    try {
      _rows.clear();
    } finally {
      _mutex.release();
    }
    notifyListeners();
  }

  /// Creates a CSV into a string
  Future<String> toCsv() async {
    final buf = StringBuffer();

    // write header row
    buf.write(CanPacket.csvHeader);

    // write each row
    await _mutex.acquire();
    try {
      for (PacketRowData row in _rows) {
        buf.write(row.packet.csvRow);
      }
    } finally {
      _mutex.release();
    }

    return buf.toString();
  }

  /// Get number of packets dropped
  int get packetsDropped => _packetsDropped;

  /// Set number packets dropped
  void addToPacketsDropped(int difference) {
    _packetsDropped += difference;
    notifyListeners();
  }

  /// Get the number of packets received
  int get packetsReceived => _packetsReceived;

  /// Increment the number of packets received
  void incrementPacketsReceived() {
    _packetsReceived++;
    notifyListeners();
  }

  /// Get the number of packets sent
  int get packetsSent => _packetsSent;

  /// Increment the number of packets sent
  void incrementPacketsSent() {
    _packetsSent++;
    notifyListeners();
  }

  /// Set all of the RX/TX stats to 0
  void resetStats() {
    _packetsDropped = 0;
    _packetsReceived = 0;
    _packetsSent = 0;
    notifyListeners();
  }
}

class RowElem extends StatelessWidget {
  final String text, desc, row;
  final Color color;
  const RowElem({
    super.key,
    required this.text,
    required this.desc,
    required this.color,
    required this.row,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: text));
      },
      child: Tooltip(
        message: desc,
        child: Text(
          text,
          style: TextStyle(
            fontFamily: "JetBrainsMono",
            color: color,
            fontSize: 14.5,
          ),
        ),
      ),
    );
  }
}

class PacketRow extends StatefulWidget {
  final PacketRowData data;
  const PacketRow({super.key, required this.data});

  @override
  State<PacketRow> createState() => _PacketRowState();
}

class _PacketRowState extends State<PacketRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    String hour = widget.data.time.hour.toString().padLeft(2, '0');
    String minute = widget.data.time.minute.toString().padLeft(2, '0');
    String second = widget.data.time.second.toString().padLeft(2, '0');
    String time = "$hour:$minute:$second";

    String uuid = widget.data.packet.uuidToHex();
    String domains =
        widget.data.packet.powerToBinary() +
        widget.data.packet.motorToBinary() +
        widget.data.packet.peripheralToBinary();
    String dlc = widget.data.packet.dlcToHex();
    String cmd = widget.data.packet.cmdToHex();
    String sender = widget.data.packet.senderUuidToHex();

    String data0 = widget.data.packet.data0ToHex();
    String data1 = widget.data.packet.data1ToHex();
    String data2 = widget.data.packet.data2ToHex();
    String data3 = widget.data.packet.data3ToHex();
    String data4 = widget.data.packet.data4ToHex();
    String data5 = widget.data.packet.data5ToHex();

    String row =
        "$time $uuid $domains $dlc $cmd $sender $data0 $data1 $data2 $data3 $data4 $data5";

    final Color accent = darkColorScheme.onPrimary;
    final Color simple = darkColorScheme.onSecondary;
    final Color highlight = darkColorScheme.surface;

    return MouseRegion(
      onEnter: (_) => setState(() {
        _isHovered = true;
      }),
      onExit: (_) => setState(() {
        _isHovered = false;
      }),
      child: Container(
        color: _isHovered ? highlight : null,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          spacing: 14,
          children: [
            // time received
            RowElem(
              text: time,
              desc: "",
              color: simple.withValues(alpha: 0.3),
              row: row,
            ),

            Row(
              spacing: 10,
              children: [
                // UUID
                RowElem(
                  text: uuid,
                  desc: "UUID (hex)",
                  color: accent,
                  row: row,
                ),
                // domains
                RowElem(
                  text: domains,
                  desc: "Domains [pow,mot,per]",
                  color: accent,
                  row: row,
                ),
              ],
            ),

            // DLC
            RowElem(text: dlc, desc: "DLC (dec)", color: simple, row: row),

            Row(
              spacing: 10,
              children: [
                // command
                RowElem(
                  text: cmd,
                  desc: "Command (hex)",
                  color: accent,
                  row: row,
                ),
                // sender
                RowElem(
                  text: sender,
                  desc: "Sender UUID (hex)",
                  color: accent,
                  row: row,
                ),
                // data 0
                RowElem(
                  text: data0,
                  desc: "Data 0 (hex)",
                  color: simple,
                  row: row,
                ),
                // data 1
                RowElem(
                  text: data1,
                  desc: "Data 1 (hex)",
                  color: simple,
                  row: row,
                ),
                // data 2
                RowElem(
                  text: data2,
                  desc: "Data 2 (hex)",
                  color: simple,
                  row: row,
                ),
                // data 3
                RowElem(
                  text: data3,
                  desc: "Data 3 (hex)",
                  color: simple,
                  row: row,
                ),
                // data 4
                RowElem(
                  text: data4,
                  desc: "Data 4 (hex)",
                  color: simple,
                  row: row,
                ),
                // data 5
                RowElem(
                  text: data5,
                  desc: "Data 5 (hex)",
                  color: simple,
                  row: row,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Terminal extends StatelessWidget {
  const Terminal({super.key});

  @override
  Widget build(BuildContext context) {
    // get list of received packets from model, updating when changed.
    List<PacketRowData> rows = Provider.of<TerminalModel>(
      context,
      listen: true,
    ).rows;

    // get number of packets dropped
    int packetsDropped = Provider.of<TerminalModel>(
      context,
      listen: true,
    ).packetsDropped;

    // get number of packets received
    int packetsReceived = Provider.of<TerminalModel>(
      context,
      listen: true,
    ).packetsReceived;

    // get number of packets sent
    int packetsSent = Provider.of<TerminalModel>(
      context,
      listen: true,
    ).packetsSent;

    return SizedBox(
      width: 460,
      child: Column(
        children: [
          // filters
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

          // output: rows of PacketRow widgets
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: darkColorScheme.secondary,
                ),
                child: (rows.isEmpty)
                    // If no packets have been received yet, display a message
                    ? Center(
                        child: Text(
                          "Packets received will appear here",
                          style: TextStyle(color: darkColorScheme.onSecondary),
                        ),
                      )
                    // Display the received packets
                    : ListView.builder(
                        itemCount: rows.length,
                        itemBuilder: (context, index) {
                          if (index >= rows.length) {
                            return null; // reached end of list, or list is empty
                          }
                          // build one PacketRow
                          return PacketRow(data: rows[index]);
                        },
                      ),
              ),
            ),
          ),

          // bottom toolbar
          Padding(
            padding: const EdgeInsets.only(
              left: 8,
              right: 8,
              bottom: 8,
              top: 6,
            ),
            child: Container(
              padding: EdgeInsets.all(6),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: 6,
                    children: [
                      // clear rows button
                      IconButton.filled(
                        onPressed: () {
                          Provider.of<TerminalModel>(
                            context,
                            listen: false,
                          ).clearAll();
                        },
                        icon: Icon(Icons.delete_sweep_outlined),
                        color: darkColorScheme.onSecondary,
                        tooltip: "Clear rows",
                      ),

                      // reset stats button
                      IconButton.filled(
                        onPressed: () {
                          Provider.of<TerminalModel>(
                            context,
                            listen: false,
                          ).resetStats();
                        },
                        icon: Icon(Icons.restart_alt_outlined),
                        color: darkColorScheme.onSecondary,
                        tooltip: "Reset stats",
                      ),
                    ],
                  ),

                  // packets sent
                  Tooltip(
                    message:
                        "This many packets were sent (receipt not verified)",
                    child: Text(
                      "Sent: $packetsSent",
                      style: TextStyle(color: darkColorScheme.onSecondary),
                    ),
                  ),

                  // packets received
                  Tooltip(
                    message:
                        "This many packets were received with a valid CRC hash",
                    child: Text(
                      "Received: $packetsReceived",
                      style: TextStyle(color: darkColorScheme.onSecondary),
                    ),
                  ),

                  // packets dropped
                  Tooltip(
                    message: "This many packets were dropped",
                    child: Text(
                      "Dropped: ${packetsDropped == 0 ? "0" : ">$packetsDropped"}",
                      style: TextStyle(color: darkColorScheme.onSecondary),
                    ),
                  ),

                  // save as CSV
                  IconButton.filled(
                    onPressed: () async {
                      // get CSV as string
                      String csv = await Provider.of<TerminalModel>(
                        context,
                        listen: false,
                      ).toCsv();

                      await FilePicker.saveFile(
                        fileName: "can-packets.csv",
                        bytes: utf8.encode(csv),
                        mimeType: "text/csv",
                        allowedExtensions: ["csv"],
                      );
                    },
                    icon: Icon(Icons.file_download_outlined),
                    color: darkColorScheme.onSecondary,
                    tooltip: "Save as CSV",
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
