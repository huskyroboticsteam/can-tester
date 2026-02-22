/// TODO
class CanPacket {
  int uuid, cmd, dlc;
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

  /// If CMD is valid, convert it to binary string representation.
  /// Otherwise, return a 8-digit wide placeholder.
  String cmdToBinary() {
    return cmdIsValid()
        ? cmd.toRadixString(2).toUpperCase().padLeft(8, "0")
        : "--------";
  }

  /// If DLC is valid, convert it to binary string representation.
  /// Otherwise, return a 4-digit wide placeholder.
  String dlcToBinary() {
    return dlcIsValid() ? dlc.toRadixString(2).padLeft(4, "0") : "----";
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
}
