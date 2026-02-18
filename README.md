MIOBREEZ EMS SDK
Библиотека для работы с десятиканальными EMS-устройствами через Bluetooth Low Energy (BLE) на Flutter с использованием flutter_blue_plus.
Позволяет сканировать устройства, подключаться, управлять параметрами, амплитудой каналов, получать заряд и управлять режимами работы устройства.
## Основные классы ### BleUtil Утилиты для работы с BLE:
dart
// Получение текущего состояния Bluetooth
BleUtil.currentState().listen((state) {
  print('Bluetooth adapter state: $state');
});
---
