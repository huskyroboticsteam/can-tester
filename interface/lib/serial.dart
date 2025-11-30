import 'package:flutter_libserialport/flutter_libserialport.dart';

// constants as registered with USB-IF
const int stVendorId = 1155;
const int stProductId = 22336;

// Search available ports for the correct board by matching
// vendor and product IDs to constants.
// Returns: the port if found, otherwise null.
SerialPort? searchAvailablePorts() {
  // get list of port names
  List<String> availablePorts = SerialPort.availablePorts;

  // iterate over list of port names
  for (String portName in availablePorts) {
    // get port attributes
    SerialPort port = SerialPort(portName);
    int? vendorId = port.vendorId;
    int? productId = port.productId;

    // check if this port corresponds to the board
    if (vendorId == stProductId && productId == stProductId) {
      return port;
    }
    port.dispose();
  }

  // could not find a port corresponding to the board
  return null;
}

// Print standard port attributes
void printPortInfo(SerialPort port) {
  print("manufacturer: ${port.manufacturer}");
  print("description : ${port.description}");
  print("vendor id:    ${port.vendorId}");
  print("product id:   ${port.productId}");
}
