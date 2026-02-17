MIOBREEZ EMS SDK
Библиотека для работы с десятиканальными EMS-устройствами через Bluetooth Low Energy (BLE) на Flutter с использованием flutter_blue_plus.
Позволяет сканировать устройства, подключаться, управлять параметрами, амплитудой каналов, получать заряд и управлять режимами работы устройства.
```dart
static Future<void> checkFat(List<int> bytes) async {
try {
await ConnectManager.getInstance().characteristic?.write(
bytes,
withoutResponse: ConnectManager.getInstance()
.characteristic!
.properties
.writeWithoutResponse,
);
} catch (e) {
if (kDebugMode) print("Write Error:");
}
}
```
