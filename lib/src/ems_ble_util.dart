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
  /// Контроллер для потока сканирования
  final _bleScanController = StreamController<ScanResult?>();

  /// Начать сканирование BLE-устройств
  Future<void> startBleScan() async {
    // Подписка на результаты сканирования
    FlutterBluePlus.scanResults.listen((event) {
      for (ScanResult element in event) {
        // Фильтруем устройства по известным именам
        if (element.device.advName.startsWith("YDSC")) {
          // Добавляем найденное устройство в поток
          _bleScanController.add(element);
        }
      }
    });

    // Запуск сканирования BLE на 10 секунд
    await FlutterBluePlus.startScan(
      withServices: [
        // При необходимости можно добавить UUID сервисов для фильтрации
         Guid.fromString(kServiceUUID),
         Guid.fromString(kServiceUUID1)
      ],
      timeout: const Duration(seconds: 10),
    );
  }

  /// Остановить сканирование BLE
  Future<void> stopBleScan() async {
    await FlutterBluePlus.stopScan();
  }

  /// Поток сканирования BLE-устройств
  /// Подписчики получают найденные ScanResult
  Stream<ScanResult?> get bleScanStream => _bleScanController.stream;
}
