import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'ems_const_data.dart';

/// Утилитарные функции для работы с BLE
class BleUtil {
  /// Экземпляр FlutterBluePlus
  FlutterBluePlus ble = FlutterBluePlus();

  /// Получить текущий статус адаптера Bluetooth
  /// Возвращает Stream состояний адаптера
  static Stream<BluetoothAdapterState> currentState() {
    return FlutterBluePlus.adapterState;
  }
}

/// Сканер BLE-устройств
class BleScanner {
  final _bleScanController = StreamController<ScanResult?>.broadcast();

  BleScanner() {
    // Подписка один раз
    FlutterBluePlus.scanResults.listen((event) {
      for (ScanResult element in event) {
        if (element.device.advName.startsWith("YDSC")) {
          _bleScanController.add(element);
        }
      }
    });
  }

  Future<void> startBleScan() async {
    await FlutterBluePlus.startScan(
      withServices: [
        Guid.fromString(kServiceUUID),
        Guid.fromString(kServiceUUID1),
      ],
      timeout: const Duration(seconds: 10),
    );
  }

  Future<void> stopBleScan() async {
    await FlutterBluePlus.stopScan();
  }

  Stream<ScanResult?> get bleScanStream => _bleScanController.stream;
}
