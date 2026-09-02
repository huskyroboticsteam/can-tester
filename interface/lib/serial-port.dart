import 'dart:async';
import 'package:can_interface/bridge.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:mutex/mutex.dart';

/// A storage container for port attributes.
class PortInfo {
  String name;
  String? description;

  PortInfo({required this.name, required this.description});
}

class PortModel extends ChangeNotifier {
  String? _selPortName; // the currently selected port
  SerialPort? _openPort; // the currently open port
  List<PortInfo> _availablePorts; // list of available ports

  SerialPortReader? _openReader; // the reader attached to _openPort
  StreamSubscription<Uint8List>? _readerSubscription; // reader sub

  final _bridge = Bridge(); // UART handlers
  final _portMutex = Mutex(); // lock for port operations

  // constructor: populate the available ports list
  PortModel() : _availablePorts = _getAvailablePorts().$1;

  // getters
  String? get selPortName => _selPortName;
  List<PortInfo> get availablePorts => _availablePorts;

  /// Update which port is selected: safely closes the old port (if any)
  /// and opens the new one. Notifies listeners of change once done.
  Future<void> setSelPortName(String? newName) async {
    await _portMutex.protect(() async {
      _selPortName = newName;

      // close/stop+dispose the old port and its reader
      await _closeOpenPortLocked();

      // open the newly selected port, if any
      if (newName != null) {
        _openSelPortLocked(newName);
      }
    });

    notifyListeners();
  }

  /// Retrieve list of ports from OS, and safely close the currently
  /// open port (since it may no longer be present/valid). Notifies
  /// listeners of change.
  Future<bool> refreshAvailablePorts() async {
    // get PortInfo list from helper
    List<PortInfo> ports;
    bool err;
    (ports, err) = _getAvailablePorts();
    if (err) {
      return false;
    }

    await _portMutex.protect(() async {
      _availablePorts = ports; // reassign list of ports
      _selPortName = null; // the user must reselect a port

      // the old selected port is no longer considered selected, so
      // make sure it's actually stopped and released
      await _closeOpenPortLocked();
    });

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
        PortInfo info = PortInfo(name: name, description: port.description);
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

  /// Safely stops and releases whatever port/reader is currently open
  /// Must only be called while holding [_portMutex].
  Future<void> _closeOpenPortLocked() async {
    // stop delivering data to our callback
    final subscription = _readerSubscription;
    _readerSubscription = null;
    if (subscription != null) {
      try {
        await subscription.cancel();
      } catch (e) {
        print("ERROR: Issue cancelling reader subscription; $e");
      }
    }

    // stop the reader's background read loop
    final reader = _openReader;
    _openReader = null;
    if (reader != null) {
      try {
        reader.close();
      } catch (e) {
        print("ERROR: Issue closing port reader; $e");
      }
    }

    // close and release the port
    final port = _openPort;
    _openPort = null;
    if (port != null) {
      try {
        if (port.isOpen) {
          port.close();
        }
        port.dispose();
      } catch (e) {
        print("ERROR: Issue disposing port; $e");
      }
    }
  }

  /// Open the selected port for read-write.
  /// Returns a [bool] indicating whether or not the port could
  /// be opened.
  /// Must only be called while holding [_portMutex], and only after
  /// [_closeOpenPortLocked] has run
  bool _openSelPortLocked(String portName) {
    try {
      // attempt to open port
      SerialPort port = SerialPort(portName);
      if (!port.openReadWrite()) {
        // could not open port
        print("ERROR: Failed to open port; ${SerialPort.lastError}");
        port.dispose();
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
      // config.dispose();

      // register read callback on port
      final reader = SerialPortReader(port);
      _openReader = reader;
      _readerSubscription = reader.stream.listen(
        (data) {
          // print the raw data
          List<String> hexList = data
              .map(
                (byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase(),
              )
              .toList();
          print(hexList);

          // main read queue handler
          _bridge.rxCallback(data);
        },
        onError: (Object e) {
          print("ERROR: Reader stream error on $portName; $e");
        },
      );
    } catch (e) {
      // could not open port
      print("ERROR: Could not open port; $e");
      return false;
    }
    return true;
  }
}
