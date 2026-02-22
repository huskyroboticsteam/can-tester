import 'package:can_interface/device-card.dart';
import 'package:can_interface/theme.dart';
import 'package:can_interface/title-bar.dart';
import 'package:can_interface/terminal.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  static const double mainMargin = 9;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(20, 18, 23, 1),
      body: Column(
        children: [
          // title bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TitleBar(),
          ),
          // everything below TitleBar should fill height
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // left side (with DeviceCards) should fill width
                Expanded(
                  child: Stack(
                    children: [
                      // scrollable list of DeviceCard widgets
                      ListView(children: [DeviceCard()]),
                      // e-stop button
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: FloatingActionButton.extended(
                            label: Text("E-STOP"),
                            onPressed: () {},
                            tooltip: "Not implemented: Send E-STOP",
                            backgroundColor: darkColorScheme.primary,
                            foregroundColor: darkColorScheme.onSecondary,
                            icon: Icon(Icons.cancel_outlined),
                          ),
                        ),
                      ),
                      // attribution/version message
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 20,
                        ),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            "Alpha 0.1.0 by Rishi Roy",
                            style: TextStyle(
                              color: darkColorScheme.onSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Terminal on right-side
                Terminal(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
