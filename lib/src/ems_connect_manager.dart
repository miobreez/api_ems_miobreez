import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:event_bus/event_bus.dart';

import '../entity/ten_device_entity.dart';

/// Менеджер подключения к BLE-устройствам
/// Использует паттерн Singleton для единственного экземпляра
class ConnectManager {
  // Единственный экземпляр класса
  static ConnectManager? _instance;

  // Приватный конструктор, чтобы предотвратить создание экземпляров извне
  ConnectManager._internal() {
    // Здесь можно добавить инициализацию
  }

  /// Получить экземпляр ConnectManager
  static ConnectManager getInstance() {
    _instance ??= ConnectManager._internal();
    return _instance!;
  }

  /// Текущее устройство сканирования
  ScanResult? currentScanResult;

  /// Список сервисов BLE
  late List<BluetoothService> _services = [];

  /// Текущее состояние подключения
  late BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;

  /// Поток состояния подключения
  late final StreamController<BluetoothConnectionState>
  _connectionStateSubscription =
  StreamController<BluetoothConnectionState>();

  /// Основная характеристика BLE
  BluetoothCharacteristic? characteristic;

  /// Характеристика для записи данных
  BluetoothCharacteristic? writeCharacteristic;

  /// Характеристика для получения уведомлений
  BluetoothCharacteristic? notifyCharacteristic;

  /// Проверка, подключено ли устройство
  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  /// Поток событий версии десятиканального устройства
  late EventBus versionTenEventBus = EventBus();

  /// Поток событий с информацией о заряде десятиканального устройства
  late EventBus powerTenEventBus = EventBus();

  /// Подключение к BLE-устройству
  Future<void> connectToDevice(ScanResult scanResult) async {
    currentScanResult = scanResult;

    // Подключение к устройству
    currentScanResult?.device.connect().then((_) {
      // После подключения — обнаруживаем сервисы
      currentScanResult?.device
          .discoverServices()
          .then((List<BluetoothService> services) {
        if (_services.isNotEmpty) _services.clear();
        _services = services;

        for (var service in services) {
          if (kDebugMode) {
            print('Service UUID: ${service.uuid}');
            print('preService UUID: ${characteristic?.uuid}');
          }

          // Обработка трёхканальных и десятиканальных устройств
          if (scanResult.device.platformName.startsWith("LS ") ||
              scanResult.device.platformName.startsWith("EM")) {
            for (var c in service.characteristics) {
              if (kDebugMode) print('Characteristic UUID: ${c.uuid}');
            }
          } else {
            for (var c in service.characteristics) {
              if (kDebugMode) print('Characteristic UUID: ${c.uuid}');
              if (c.uuid.toString().toUpperCase() == "FFB2") {
                setNotifyCha(c);
                characteristic = c;
              }
            }
          }

          // Устройство подключено
          _connectionStateSubscription.add(BluetoothConnectionState.connected);
        }
      }).catchError((error) {
        // Ошибка при обнаружении сервисов
        _connectionState = BluetoothConnectionState.disconnected;
        _connectionStateSubscription.add(BluetoothConnectionState.disconnected);
        if (kDebugMode) print('Error discovering services: $error');
      });
    }).catchError((error) {
      // Ошибка при подключении
      _connectionState = BluetoothConnectionState.disconnected;
      _connectionStateSubscription.add(BluetoothConnectionState.disconnected);
      if (kDebugMode) print('Error connecting to device: $error');
    });
  }

  /// Поток состояний BLE-подключения
  Stream<BluetoothConnectionState> get bleConnectStream =>
      _connectionStateSubscription.stream;

  /// Подписка на уведомления от характеристики
  void setNotifyCha(BluetoothCharacteristic character) {
    character.setNotifyValue(true).then((_) {
      character.lastValueStream.listen((event) {
        if (kDebugMode) {
          print('received data: $event, cha:${character.uuid.toString()}');
        }
        controlData(event);
      });
    });
  }

  /// Обработка данных, полученных от устройства
  void controlData(List<int> list) {
    if (list.isEmpty) return;

    // ---------------- Информация о заряде десятиканального устройства ----------------
    if (list[0] == 0x3b &&
        list[1] == 0x00 &&
        list[2] == 0x0a &&
        list[3] == 0x00 &&
        list[4] == 0x0a) {
      TenDevicePower tenDevicePower = TenDevicePower();
      if (list[5] == 0x55) {
        tenDevicePower.percent = list[6];
        tenDevicePower.mode = list[7];
      }
      powerTenEventBus.fire(tenDevicePower);
      powerTenEventBus.destroy();
      powerTenEventBus = EventBus();
    }

  }
}
