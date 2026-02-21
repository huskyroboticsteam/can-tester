import 'dart:ffi';
import 'dart:typed_data';

import 'package:can_interface/dashboard.dart';
import 'package:can_interface/serial.dart';
import 'package:can_interface/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // get port that corresponds to board
    SerialPort? port = searchAvailablePorts();

    if (port == null) {
      print("Could not find board serial port");
    } else {
      // print info about port
      printPortInfo(port);

      // open serial port
      if (!port.openReadWrite()) {
        print(SerialPort.lastError);
      } else {
        // write to port
        final testMsg = "TESTING.";
        print("wrote test msg");
        print(testMsg.codeUnits);
        port.write(Uint8List.fromList(testMsg.codeUnits));

        // read callback
        final reader = SerialPortReader(port);
        reader.stream.listen((data) {
          String str = String.fromCharCodes(data);
          print("received: $str");
        });
      }
    }

    return MaterialApp(
      title: "CAN Tester",
      theme: ThemeData(colorScheme: darkColorScheme),
      debugShowCheckedModeBanner: false, // hide debug banner
      home: Dashboard(),
    );
  }
}
