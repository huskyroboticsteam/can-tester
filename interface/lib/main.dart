import 'dart:typed_data';

import 'package:can_interface/dashboard.dart';
import 'package:can_interface/serial-port.dart';
import 'package:can_interface/serial.dart';
import 'package:can_interface/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PortModel(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // get port that corresponds to board
    // SerialPort? port = searchAvailablePorts();

    List<String> availablePorts = SerialPort.availablePorts;

    // iterate over list of port names
    for (String portName in availablePorts) {
      try {
        // get port attributes
        SerialPort port = SerialPort(portName);
        int? vendorId = port.vendorId;
        int? productId = port.productId;

        print("PORT $portName ${port.description} (${port.vendorId}, ${port.productId})");

        port.dispose();
      } catch (e) {
        print(e);
      }
    }

    // if (port == null) {
    //   print("Could not find board serial port");
    // } else {
    //   // print info about port
    //   printPortInfo(port);

    //   // open serial port
    //   if (!port.openReadWrite()) {
    //     print(SerialPort.lastError);
    //   } else {
    //     // write to port
    //     final testMsg = "TESTING.";
    //     print("wrote test msg");
    //     print(testMsg.codeUnits);
    //     port.write(Uint8List.fromList(testMsg.codeUnits));

    //     // read callback
    //     final reader = SerialPortReader(port);
    //     reader.stream.listen((data) {
    //       String str = String.fromCharCodes(data);
    //       print("received: $str");
    //     });
    //   }
    // }

    return MaterialApp(
      title: "CAN Tester",
      theme: ThemeData(colorScheme: darkColorScheme),
      // debugShowCheckedModeBanner: false, // hide debug banner
      home: Dashboard(),
    );
  }
}
