library dart_ems_sdk;

export 'src/ems_ble_util.dart';
export 'src/ems_func_ten_api.dart';
export 'src/ems_const_data.dart';
export 'package:flutter_blue_plus/flutter_blue_plus.dart';
export 'src/ems_connect_manager.dart';

/// Статус соединения Bluetooth
enum EmsBluetoothConnectionState {
  disconnected,
  connected,
}
