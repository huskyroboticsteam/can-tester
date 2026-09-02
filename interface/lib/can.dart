/// TODO
class CanPacket {
  int uuid, cmd, dlc, senderUuid;
  bool priority, power, motor, peripheral;
  List<int> data;

  CanPacket({
    required this.uuid,
    required this.cmd,
    required this.dlc,
    required this.priority,
    required this.power,
    required this.motor,
    required this.peripheral,
    required this.data,
    required this.senderUuid,
  });

  /// Verify UUID is 7-bit unsigned int.
  bool uuidIsValid() {
    return uuid <= 127 && uuid >= 0;
  }

  /// Verify CMD is 8-bit unsigned int.
  bool cmdIsValid() {
    return cmd <= 255 && cmd >= 0;
  }

  /// Verify DLC is in range 0 to 8.
  bool dlcIsValid() {
    return dlc <= 8 && dlc >= 0;
  }

  /// If UUID is valid, convert it to binary string representation.
  /// Otherwise, return a 7-digit wide placeholder.
  String uuidToBinary() {
    return uuidIsValid() ? uuid.toRadixString(2).padLeft(7, "0") : "-------";
  }

  String uuidToHex() {
    return uuid.toRadixString(16).padLeft(2, '0');
  }

  /// If CMD is valid, convert it to binary string representation.
  /// Otherwise, return a 8-digit wide placeholder.
  String cmdToBinary() {
    return cmdIsValid()
        ? cmd.toRadixString(2).toUpperCase().padLeft(8, "0")
        : "--------";
  }

  String cmdToHex() {
    return cmd.toRadixString(16).padLeft(2, '0');
  }

  String senderUuidToHex() {
    return senderUuid.toRadixString(16).padLeft(2, '0');
  }

  /// If DLC is valid, convert it to binary string representation.
  /// Otherwise, return a 4-digit wide placeholder.
  String dlcToBinary() {
    return dlcIsValid() ? dlc.toRadixString(2).padLeft(4, "0") : "----";
  }

  String dlcToHex() {
    return dlc.toRadixString(16);
  }

  /// Convert priority bit to binary string representation.
  String priorityToBinary() {
    return priority ? "1" : "0";
  }

  /// Convert priority bit to binary string representation.
  String powerToBinary() {
    return power ? "1" : "0";
  }

  /// Convert priority bit to binary string representation.
  String motorToBinary() {
    return motor ? "1" : "0";
  }

  /// Convert priority bit to binary string representation.
  String peripheralToBinary() {
    return peripheral ? "1" : "0";
  }

  /// Generate 11-bit binary string representation of full address.
  String addressBinary() {
    return priorityToBinary() +
        uuidToBinary() +
        powerToBinary() +
        motorToBinary() +
        peripheralToBinary();
  }

  String data0ToHex() {
    if (data.isEmpty) {
      return "";
    }
    return data[0].toRadixString(16).padLeft(2, '0');
  }

  String data1ToHex() {
    if (data.length < 2) {
      return "";
    }
    return data[1].toRadixString(16).padLeft(2, '0');
  }

  String data2ToHex() {
    if (data.length < 3) {
      return "";
    }
    return data[2].toRadixString(16).padLeft(2, '0');
  }

  String data3ToHex() {
    if (data.length < 4) {
      return "";
    }
    return data[3].toRadixString(16).padLeft(2, '0');
  }

  String data4ToHex() {
    if (data.length < 3) {
      return "";
    }
    return data[4].toRadixString(16).padLeft(2, '0');
  }

  String data5ToHex() {
    if (data.length < 6) {
      return "";
    }
    return data[5].toRadixString(16).padLeft(2, '0');
  }

  String get domains => powerToBinary() + motorToBinary() + peripheralToBinary();

  static String get csvHeader =>
      "UUID, Domains, Data Len, Command, Sender UUID, "
      "Data 0, Data 1, Data 2, Data 3, Data 4, Data 5\n";

  String get csvRow =>
      "${uuidToHex()}, $domains, $dlc, $cmd, ${senderUuidToHex()}, "
      "${data0ToHex()}, ${data1ToHex()}, ${data2ToHex()}, ${data3ToHex()}, ${data4ToHex()}, ${data5ToHex()}\n";
}
