import 'dart:collection';
import 'package:can_interface/can.dart';
import 'package:can_interface/terminal.dart';
import 'dart:typed_data';

import 'package:crclib/crclib.dart';

const int uartFrameSize = 14;
const int uartStartCode = 0xF0;
const int _lastRxIndex = 0;

// CRC8 calculation parameters that match the esp_rom_crc8_le() function
final espCrc8 = ParametricCrc(
  8, // width
  0x07, // polynomial
  0xFF, // initial value: ~0x00
  0xFF, // final mask: ~0x00
  inputReflected: true,
  outputReflected: true,
);

// Dart is single-threaded, so a simple boolean mutex works fine
class Mutex {
  bool _taken;

  Mutex() : _taken = false;

  Future<void> acquire() async {
    while (_taken) {
      await Future.delayed(const Duration(milliseconds: 5));
    }
    _taken = true;
  }

  void release() {
    _taken = false;
  }
}

class Bridge {
  final ListQueue<int> _rxQueue = ListQueue(50);
  final _mutex = Mutex();
  final TerminalModel _term = TerminalModel();

  Bridge();

  void rxCallback(Uint8List data) async {
    await _mutex.acquire(); // lock

    // push the new data into the read queue
    for (int i = 0; i < data.length; i++) {
      _rxQueue.add(data[i]);
    }

    if (_rxQueue.length < uartFrameSize) {
      // we don't have a full frame yet
      _mutex.release(); // release mutex
      return;
    }

    while (_rxQueue.length >= uartFrameSize) {
      // look for the UART frame start code
      while (_rxQueue.isNotEmpty && _rxQueue.first != uartStartCode) {
        _rxQueue.removeFirst();
      }

      if (_rxQueue.length < uartFrameSize) {
        _mutex.release(); // release
        return;
      }

      // copy UART frame and the CRC byte separately
      List<int> uFrame = _rxQueue.take(uartFrameSize - 1).toList();
      int expectedCrc = _rxQueue.elementAt(uartFrameSize - 1);
      assert(uFrame[0] == uartStartCode);

      // check CRC
      int calculatedCrc = espCrc8.convert(uFrame).toBigInt().toInt();
      if (calculatedCrc != expectedCrc) {
        // CRC does not match
        _rxQueue.removeFirst(); // discard the first start code
        _mutex.release(); // release mutex
        return;
      }

      // we have a full UART frame, so remove these bytes from the queue
      for (int i = 0; i < uartFrameSize; i++) {
        _rxQueue.removeFirst();
      }

      // assemble a CAN packet
      int deviceId = (uFrame[2] << 8) + uFrame[3];
      bool peripheral = deviceId & 0x1 == 1 ? true : false;
      bool motor = (deviceId >> 1) & 0x1 == 1 ? true : false;
      bool power = (deviceId >> 2) & 0x1 == 1 ? true : false;
      int uuid = (deviceId >> 3) & 0x7F;
      bool priority = (deviceId >> 10) == 1 ? true : false;
      int dlc = uFrame[4] + 2; // TODO: subtract 2
      int command = uFrame[5];
      int senderUuid = uFrame[6];
      List<int> contents = [];
      for (int i = 0; i < 6; i++) {
        contents.add(uFrame[7 + i]);
      }

      final canPacket = CanPacket(
        uuid: uuid,
        cmd: command,
        dlc: dlc,
        priority: priority,
        power: power,
        motor: motor,
        peripheral: peripheral,
        data: contents,
        senderUuid: senderUuid,
      );

      // push CAN packet to terminal model; updates UI
      final packetRow = PacketRowData(packet: canPacket, time: DateTime.now());
      _term.addRow(packetRow);
    }

    _mutex.release();
  }
}
