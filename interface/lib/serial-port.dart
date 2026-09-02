import 'package:can_interface/bridge.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

/// A storage container for port attributes.
class PortInfo {
  String name;
  String? description;
  int? vendorId, productId;

  PortInfo({
    required this.name,
    required this.description,
    required this.vendorId,
    required this.productId,
  });
}

class PortModel extends ChangeNotifier {
  String? _selPortName; // the currently selected port
  List<PortInfo> _availablePorts; // list of available ports
  SerialPort? _openPort; // the currently open port
  final _bridge = Bridge();

  // constructor: populate the available ports list
  PortModel() : _availablePorts = _getAvailablePorts().$1;

  // getters
  String? get selPortName => _selPortName;
  List<PortInfo> get availablePorts => _availablePorts;

  /// Update which port is selected. Notifies listeners of change.
  void setSelPortName(String? newName) {
    _selPortName = newName;

    // close the old port
    _openPort?.dispose();

    // open port
    _openSelPort();

    notifyListeners();
  }

  /// Retrieve list of ports from OS. Notifies listeners of change.
  bool refreshAvailablePorts() {
    // get PortInfo list from helper
    List<PortInfo> ports;
    bool err;
    (ports, err) = _getAvailablePorts();
    if (err) {
      return false;
    }

    _availablePorts = ports; // reassign list of ports
    _selPortName = null; // the user must reselect a port

    notifyListeners();
    return true;
  }

  /// Retrieve list of ports from OS. Returns the list, and does
  /// not modify this instance's data members.
  static (List<PortInfo>, bool err) _getAvailablePorts() {
    List<PortInfo> res = [];

    // get port names from OS
    final List<String>? portNames;
    try {
      portNames = SerialPort.availablePorts;
    } catch (_) {
      print("ERROR: Could not get port names; ${SerialPort.lastError}");
      return ([], true);
    }

    // extract port attributes for each port name, and store in list
    // if an exception is thrown on one port, skip it but log the error
    for (String name in portNames) {
      try {
        // get serial port instance
        final SerialPort port = SerialPort(name);

        // extract port attributes
        PortInfo info = PortInfo(
          name: name,
          description: port.description,
          vendorId: port.vendorId,
          productId: port.productId,
        );
        res.add(info);

        // release resources
        port.dispose();
      } catch (_) {
        // an error occured on this specific port
        print("ERROR: Issue with port $name; ${SerialPort.lastError}");
      }
    }
    return (res, false);
  }

  /// Open the selected port for read-write.
  /// Returns a [bool] indicating whether or not the port could
  /// be opened.
  bool _openSelPort() {
    String? portName = _selPortName;
    if (portName == null) {
      return false; // no port selected
    }

    try {
      // attempt to open port
      SerialPort port = SerialPort(portName);
      if (!port.openReadWrite()) {
        // could not open port
        print("ERROR: Failed to open port; ${SerialPort.lastError}");
        return false;
      }
      print("Opened port: $portName");
      _openPort = port;

      // port configuration
      final config = SerialPortConfig();
      config.baudRate = 115200; // set baud rate
      config.bits = 8;
      config.parity = SerialPortParity.none;
      config.stopBits = 1;
      port.config = config;
      config.dispose();

      // register read callback on port
      final reader = SerialPortReader(port);
      reader.stream.listen((data) {
        // print the raw data
        List<String> hexList = data
            .map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase())
            .toList();
        print(hexList);

        // main read queue handler
        _bridge.rxCallback(data);
      });
    } catch (e) {
      // could not open port
      print("ERROR: Could not open port; $e");
      return false;
    }
    return true;
  }
}
