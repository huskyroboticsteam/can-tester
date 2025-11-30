import 'package:can_interface/dashboard.dart';
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
    // list available serial ports
    List<String> availablePorts = SerialPort.availablePorts;
    print(availablePorts);

    // get specific (3rd) serial port
    String portName = availablePorts[2];
    print("opening $portName");
    SerialPort port = SerialPort(portName);

    // print info about port
    print("description : ${port.description}");
    print("manufacturer: ${port.manufacturer}");
    print("vendor id:    ${port.vendorId}");  // should be 1155
    print("product id:   ${port.productId}"); // should be 22336
    print("product name: ${port.productName}");


    // open serial port
    if (!port.openReadWrite()) {
      print(SerialPort.lastError);
    } else {
      // read callback for port
      final reader = SerialPortReader(port);
      reader.stream.listen((data) {
        // callback
        String str = String.fromCharCodes(data);
        // print("received: $data");
        print("received: $str");
      });
    }

    return MaterialApp(
      title: "CAN Tester",
      theme: ThemeData(colorScheme: darkColorScheme),
      debugShowCheckedModeBanner: false, // hide debug banner
      home: Dashboard(),
    );
  }
}
