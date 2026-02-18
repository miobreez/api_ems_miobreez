# Dart EMS SDK

Библиотека для управления **десятиканальными EMS-устройствами** через **Bluetooth Low Energy (BLE)** на Flutter с использованием `flutter_blue_plus`.

SDK позволяет:

- 🔍 Сканировать BLE-устройства  
- 🔗 Подключаться к устройству  
- ⚙️ Отправлять параметры работы  
- 🎚 Управлять амплитудой каналов  
- 🔋 Получать уровень заряда  
- ▶️ Управлять режимами работы (Start / Pause / Stop)

---

## 📦 Установка

Добавьте зависимость в `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_blue_plus: ^2.1.1
  dart_ems_sdk:
    path: ../path_to_your_sdk
```

---

## 📥 Импорт

```dart
import 'package:dart_ems_sdk/dart_ems_sdk.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
```

---

# 🧩 Основные компоненты SDK

---

## 🔵 BleUtil

Утилиты для работы с BLE.

### Получение состояния Bluetooth:

```dart
BleUtil.currentState().listen((state) {
  print('Bluetooth adapter state: $state');
});
```

---

## 🔍 BleScanner

Сканирование BLE-устройств.

```dart
final scanner = BleScanner();

// ▶ Начать сканирование
await scanner.startBleScan();

// 📡 Поток найденных устройств
scanner.bleScanStream.listen((scanResult) {
  if (scanResult != null) {
    print('Найдено устройство: ${scanResult.device.name}');
  }
});

// ⛔ Остановить сканирование
await scanner.stopBleScan();
```

---

## 🔗 ConnectManager

Менеджер подключения (Singleton).

```dart
final manager = ConnectManager.getInstance();

// Подключение к устройству
await manager.connectToDevice(scanResult);

// Поток состояния соединения
manager.bleConnectStream.listen((state) {
  print('Connection state: $state');
});
```

### Важные свойства и методы:

- `characteristic` — основная BLE-характеристика для записи  
- `setNotifyCha(characteristic)` — подписка на уведомления  
- `controlData(List<int> data)` — обработка входящих данных  

---

# ⚡ EmsTenFuncManager

Основной класс для управления EMS-устройством.

---

## ⚙️ Отправка параметров работы

```dart
await EmsTenFuncManager.sendParam((success) {
  if (success) {
    print('Параметры успешно отправлены');
  } else {
    print('Ошибка отправки параметров');
  }
});
```
---

## 🎮 Управление устройством

### ▶ Старт

```dart
await EmsTenFuncManager.controlDevice(
  TenControlDeviceType.start,
  (success) => print(success ? 'Устройство запущено' : 'Ошибка старта'),
);
```

### ⏸ Пауза

```dart
await EmsTenFuncManager.controlDevice(
  TenControlDeviceType.pause,
  (success) => print(success ? 'Пауза установлена' : 'Ошибка паузы'),
);
```

### ▶ Продолжение

```dart
await EmsTenFuncManager.controlDevice(
  TenControlDeviceType.continues,
  (success) => print(success ? 'Возобновлено' : 'Ошибка продолжения'),
);
```

### ⛔ Стоп

```dart
await EmsTenFuncManager.controlDevice(
  TenControlDeviceType.end,
  (success) => print(success ? 'Устройство остановлено' : 'Ошибка остановки'),
);
```

---

## 🎚 Отправка амплитуды каналов

> Список из 10 значений (максимум 100)

```dart
await EmsTenFuncManager.sendStrength(
  [50, 60, 70, 80, 90, 50, 60, 70, 80, 90],
  (success) => print(success ? 'Амплитуда отправлена' : 'Ошибка отправки'),
);
```

---

## 🔋 Получение заряда устройства

```dart
await EmsTenFuncManager.getPower((isSuccess, tenDevicePower) {
  if (isSuccess) {
    print('Заряд: ${tenDevicePower.percent}%');
    print('Режим работы: ${tenDevicePower.mode}');
  } else {
    print('Не удалось получить заряд');
  }
});
```

---

## 🔌 Выключение устройства

```dart
await EmsTenFuncManager.closeDevice((success) {
  print(success ? 'Устройство выключено' : 'Ошибка выключения');
});
```

---

# 🔄 Полный пример цикла работы

```dart
final scanner = BleScanner();
final manager = ConnectManager.getInstance();

// 1️⃣ Сканирование
await scanner.startBleScan();

// 2️⃣ Подключение
await manager.connectToDevice(scanResult);

// 3️⃣ Отправка параметров
await EmsTenFuncManager.sendParam((_) {});

// 4️⃣ Запуск устройства
await EmsTenFuncManager.controlDevice(
  TenControlDeviceType.start,
  (_) {},
);

// 5️⃣ Получение заряда
await EmsTenFuncManager.getPower((_, power) {
  print(power.percent);
});

// 6️⃣ Остановка
await EmsTenFuncManager.controlDevice(
  TenControlDeviceType.end,
  (_) {},
);
```

---

# 📝 Примечания

- Все команды отправляются в виде готовых байтовых пакетов  
- Пользователю не нужно рассчитывать контрольные суммы  
- Используется потоковая модель для получения данных  
- Устройства фильтруются по имени и UUID сервисов  
