import 'package:can_interface/widgets.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  static const double mainMargin = 9;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 95, right: 30),
                      child: Text(
                        "CAN Tester 0.1.0",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 40,
                        margin: EdgeInsets.symmetric(vertical: mainMargin),
                        child: BoldCard(
                          child: Center(child: Text("Menu Items Here")),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            width: 450,
            margin: EdgeInsets.all(mainMargin),
            child: BoldCard(child: Column(children: [Text("Output Here")])),
          ),
        ],
      ),
    );
  }
}
