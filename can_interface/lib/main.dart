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

    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
