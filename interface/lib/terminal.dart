import 'package:can_interface/can.dart';
import 'package:flutter/material.dart';
import 'package:can_interface/theme.dart';
import 'package:provider/provider.dart';

// Singleton to hold list of received packets and update UI
class TerminalModel extends ChangeNotifier {
  final List<CanPacket> _receivedPackets;

  // singleton instance
  static final TerminalModel _instance = TerminalModel._internal();

  // private constructor to initialize empty list
  TerminalModel._internal() : _receivedPackets = [];

  // factory constructor returns the same instance every time
  factory TerminalModel() => _instance;

  // Get list of received CAN packets
  List<CanPacket> get receivedPackets => _receivedPackets;

  // Appends a newly received CAN packet to the back of the model's list.
  // Notifies listeners.
  void addPacket(CanPacket packet) {
    _receivedPackets.add(packet);
    notifyListeners();
  }
}

class PacketRow extends StatelessWidget {
  final CanPacket packet;
  const PacketRow({super.key, required this.packet});

  @override
  Widget build(BuildContext context) {
    return Container(child: Text(packet.uuid.toRadixString(16)));
  }
}

class Terminal extends StatelessWidget {
  const Terminal({super.key});

  @override
  Widget build(BuildContext context) {
    // Get list of received packets from model, updating when changed.
    List<CanPacket> packets = Provider.of<TerminalModel>(
      context,
      listen: true,
    ).receivedPackets;

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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: darkColorScheme.secondary,
                ),
                child: ListView.builder(
                  itemCount: packets.length,
                  itemBuilder: (context, index) {
                    if (index >= packets.length) {
                      return null; // reached end of list, or list is empty
                    }
                    // build one PacketRow
                    return PacketRow(packet: packets[index]);
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
