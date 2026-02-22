import 'package:flutter/foundation.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class PortModel extends ChangeNotifier {
  List<String> _availablePorts;
  String? _selPortName;
  List<String> _receivedPackets = [];

  PortModel() : _availablePorts = _getAvailablePorts();

  List<String> get availablePorts => _availablePorts;
  List<String> get receivedPackets => _receivedPackets;
  String? get selPortName => _selPortName;

  void setSelPortName(String? newName) {
    _selPortName = newName;
    notifyListeners();
  }

  /// Retrieve list of ports from OS. Notifies listeners of change.
  bool refreshAvailablePorts() {
    try {
      _availablePorts = SerialPort.availablePorts;
      notifyListeners();
      return true;
    } catch (_) {
      print("ERROR: Could not refresh ports; ${SerialPort.lastError}");
      return false;
    }
  }

  /// Retrieve list of ports from OS. Returns the list, and does
  /// not modify this instance's data members.
  static List<String> _getAvailablePorts() {
    try {
      return SerialPort.availablePorts;
    } catch (_) {
      print("ERROR: Could not refresh ports; ${SerialPort.lastError}");
      return [];
    }
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
  void _readCallback(Uint8List data) {
    String str = String.fromCharCodes(data);
    print("RECEIVED: $str");

    receivedPackets.add(str);
    notifyListeners();
  }
}
