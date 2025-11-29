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
    final availablePorts = SerialPort.availablePorts;
    print(availablePorts);

    return MaterialApp(
      title: "CAN Tester",
      theme: ThemeData(colorScheme: darkColorScheme),
      debugShowCheckedModeBanner: false,  // hide debug banner
      home: Dashboard()
    );
  }
}
