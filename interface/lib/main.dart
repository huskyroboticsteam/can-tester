import 'package:can_interface/dashboard.dart';
import 'package:can_interface/serial-port.dart';
import 'package:can_interface/terminal.dart';
import 'package:can_interface/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PortModel()),
        ChangeNotifierProvider.value(
          value: TerminalModel(),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> availablePorts = SerialPort.availablePorts;

    // iterate over list of port names
    for (String portName in availablePorts) {
      try {
        // get port attributes
        SerialPort port = SerialPort(portName);
        int? vendorId = port.vendorId;
        int? productId = port.productId;

        print(
          "PORT $portName ${port.description} (${port.vendorId}, ${port.productId})",
        );

        port.dispose();
      } catch (e) {
        print(e);
      }
    }

    return MaterialApp(
      title: "CAN Tester",
      theme: ThemeData(colorScheme: darkColorScheme),
      home: Dashboard(),
    );
  }
}
