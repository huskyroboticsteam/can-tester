import 'package:can_interface/can.dart';
import 'package:flutter/material.dart';
import 'package:can_interface/theme.dart';
import 'package:provider/provider.dart';

class PacketRowData {
  final CanPacket packet;
  final DateTime time;

  PacketRowData({required this.packet, required this.time});
}

// Singleton to hold list of received packets and update UI
class TerminalModel extends ChangeNotifier {
  final List<PacketRowData> _rows;

  // singleton instance
  static final TerminalModel _instance = TerminalModel._internal();

  // private constructor to initialize empty list
  TerminalModel._internal() : _rows = [];

  // factory constructor returns the same instance every time
  factory TerminalModel() => _instance;

  // Get list of received CAN packets
  List<PacketRowData> get rows => _rows;

  // Appends a newly received CAN packet to the back of the model's list.
  // Notifies listeners.
  void addRow(PacketRowData row) {
    _rows.add(row);
    notifyListeners();
  }
}

class PacketRow extends StatelessWidget {
  final PacketRowData data;
  const PacketRow({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    String hour = data.time.hour.toString().padLeft(2, '0');
    String minute = data.time.minute.toString().padLeft(2, '0');
    String second = data.time.second.toString().padLeft(2, '0');
    String uuid = data.packet.uuid.toRadixString(16).padLeft(2, '0');
    String dlc = data.packet.dlc.toRadixString(10);
    String cmd = data.packet.cmd.toRadixString(16).padLeft(2, '0');

    return Row(
      spacing: 10,
      children: [
        // Time received
        Tooltip(
          message: "Time received",
          child: Text(
            "$hour:$minute:$second",
            style: TextStyle(
              fontFamily: "JetBrainsMono",
              color: darkColorScheme.onPrimary,
            ),
          ),
        ),
        // UUID
        Tooltip(
          message: "UUID (hex)",
          child: Text(
            uuid,
            style: TextStyle(
              fontFamily: "JetBrainsMono",
              color: darkColorScheme.onSecondary,
            ),
          ),
        ),
        // DLC
        Tooltip(
          message: "DLC (dec)",
          child: Text(
            dlc,
            style: TextStyle(
              fontFamily: "JetBrainsMono",
              color: darkColorScheme.onSecondary,
            ),
          ),
        ),
        // Command
        Tooltip(
          message: "Command (hex)",
          child: Text(
            cmd,
            style: TextStyle(
              fontFamily: "JetBrainsMono",
              color: darkColorScheme.onSecondary,
            ),
          ),
        ),
        // TODO: data
      ],
    );
  }
}

class Terminal extends StatelessWidget {
  const Terminal({super.key});

  @override
  Widget build(BuildContext context) {
    // Get list of received packets from model, updating when changed.
    List<PacketRowData> rows = Provider.of<TerminalModel>(
      context,
      listen: true,
    ).rows;

    return SizedBox(
      width: 477,
      child: Column(
        children: [
          // Terminal filters
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
          // Terminal output: rows of PacketRow widgets
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
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
