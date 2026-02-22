import 'package:can_interface/serial-port.dart';
import 'package:flutter/material.dart';
import 'package:can_interface/theme.dart';
import 'package:provider/provider.dart';

class PortSelector extends StatefulWidget {
  const PortSelector({super.key});

  @override
  State<PortSelector> createState() => _PortSelectorState();
}

class _PortSelectorState extends State<PortSelector> {
  @override
  Widget build(BuildContext context) {
    // listen/get list of port names from model
    List<PortInfo> availablePorts = Provider.of<PortModel>(
      context,
      listen: true,
    ).availablePorts;

    return Consumer<PortModel>(
      builder: (context, model, child) {
        return Container(
          decoration: BoxDecoration(
            color: darkColorScheme.secondary,
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 8),
                child: DropdownButton<String>(
                  value: Provider.of<PortModel>(
                    context,
                    listen: true,
                  ).selPortName,
                  onChanged: (newName) {
                    Provider.of<PortModel>(
                      context,
                      listen: false,
                    ).setSelPortName(newName);
                  },
                  hint: Text(
                    (availablePorts.isEmpty ? "No Ports Found" : "Select Port"),
                    style: TextStyle(color: darkColorScheme.onPrimary),
                  ),
                  dropdownColor: darkColorScheme.secondary,
                  underline: Container(
                    // remove underline
                    height: 0,
                  ),
                  items: availablePorts.map<DropdownMenuItem<String>>((
                    portInfo,
                  ) {
                    return DropdownMenuItem<String>(
                      value: portInfo.name,
                      child: SizedBox(
                        width: 240,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 3, bottom: 0),
                              child: Text(
                                portInfo.name,
                                style: TextStyle(
                                  color: darkColorScheme.onPrimary,
                                  fontSize: 14.5,
                                  fontFamily: "JetBrainsMono",
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Text(
                              portInfo.description ?? "--",
                              style: TextStyle(
                                color: darkColorScheme.onSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                child: IconButton(
                  icon: Icon(Icons.refresh_rounded),
                  tooltip: "Refresh ports",
                  color: darkColorScheme.onPrimary,
                  onPressed: () {
                    // trigger a refresh of the ports list in PortModel
                    bool refreshSuccess = Provider.of<PortModel>(
                      context,
                      listen: false,
                    ).refreshAvailablePorts();
                    // display snackbar with success or error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Center(
                          child: Text(
                            (refreshSuccess
                                ? "Successfully refreshed ports list"
                                : "ERROR: Could not retrieve available ports"),
                            style: TextStyle(
                              color: darkColorScheme.onSecondary,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        backgroundColor: (refreshSuccess
                            ? darkColorScheme.primary
                            : darkColorScheme.error),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.6,
        child: Card.filled(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          color: darkColorScheme.primary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  "CAN Tester",
                  style: TextStyle(
                    color: darkColorScheme.onSecondary,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PortSelector(),
                    Padding(
                      padding: EdgeInsets.only(left: 4, right: 2),
                      child: IconButton(
                        color: darkColorScheme.onSecondary,
                        onPressed: () {},
                        icon: Icon(Icons.bug_report_outlined),
                        tooltip: "Not implemented: Issues",
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: IconButton(
                        color: darkColorScheme.onSecondary,
                        onPressed: () {},
                        icon: Icon(Icons.help_outline_rounded),
                        tooltip: "Not implemented: Help",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 2, right: 8),
                      child: IconButton(
                        color: darkColorScheme.onSecondary,
                        onPressed: () {},
                        icon: Icon(Icons.add_rounded),
                        tooltip: "Not implemented: Add another device",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
