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
  // List<String> _availablePorts;
  String? _selPortName;
  List<PortInfo> _availablePorts;

  PortModel() : _availablePorts = _getAvailablePorts().$1;

  List<PortInfo> get availablePorts => _availablePorts;
  String? get selPortName => _selPortName;

  void setSelPortName(String? newName) {
    _selPortName = newName;
    notifyListeners();
  }

  /// Retrieve list of ports from OS. Notifies listeners of change.
  bool refreshAvailablePorts() {
    // get PortInfo list from helper
    List<PortInfo> ports;
    bool err;
    (ports, err) = _getAvailablePorts();
    _availablePorts = ports;

    // prevent crashing when the selected USB device is disconnected
    _selPortName = null;

    notifyListeners();

    return !err;
  }

  /// Retrieve list of ports from OS. Returns the list, and does
  /// not modify this instance's data members.
  /// Returns: TODO
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
    // cannot open if port is not selected
    if (portName == null) {
      return false;
    }

    // attempt to open port
    try {
      SerialPort port = SerialPort(portName);
      if (!port.openReadWrite()) {
        // could not open port
        print(SerialPort.lastError);
      } else {
        // register read callback on port
        final reader = SerialPortReader(port);
        reader.stream.listen((data) {
          String str = String.fromCharCodes(data);
          print("received: $str");
        });
      }
    } catch (e) {
      // could not open port
      print("ERROR: Could not open port; $e");
      return false;
    }
    return true;
  }

  /// Callback to read data from port, adding received to a list
  /// dislayed by Terminal
  // void _readCallback(Uint8List data) {
  //   String str = String.fromCharCodes(data);
  //   print("RECEIVED: $str");

  //   receivedPackets.add(str);
  //   notifyListeners();
  // }
}
