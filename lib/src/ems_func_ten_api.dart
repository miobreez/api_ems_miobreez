import 'package:flutter/foundation.dart';

import '../entity/ten_device_entity.dart';
import 'ems_connect_manager.dart';

/// Типы управления десятиканальным устройством
enum TenControlDeviceType { start, end, pause, continues }

/// Колбэки
typedef CallBackTenVersion = void Function(bool isSuccess, String version);
typedef CallBackTenWriteStatus = void Function(bool isSuccess);
typedef CallBackPower =
    void Function(bool isSuccess, TenDevicePower tenDevicePower);
typedef CallBackWriteStatus = void Function(bool isSuccess);

/// Менеджер функций для десятиканального EMS-устройства
class EmsTenFuncManager {
  /// Отправка параметров работы устройства
  /// frequency - частота, pulseWidth - ширина импульса
  /// fundamentalWave - основная волна, carrierWave - несущая волна
  /// duration - время работы, interval - время отдыха
  static Future<void> sendParam(
      CallBackTenWriteStatus callBackTenWriteStatus) async {
    int bufferTime = 15;
    int pulseWidth = 30 ;
    int frequency = 50;
    int fundamentalWave = 1;
    int carrierWave = 1;
    int duration = 30;
    int interval = 2;
    int valid = (0x3B +
        0x00 +
        0x14 +
        0x00 +
        0x01 +
        frequency +
        pulseWidth +
        fundamentalWave +
        carrierWave +
        0x00 +
        bufferTime +
        0x00 +
        duration +
        0x00 +
        bufferTime +
        0x00 +
        interval) &
    0xff;
    List<int> param = [
      0x3B,
      0x00,
      0x14,
      0x00,
      0x01,
      0x00,
      frequency,
      pulseWidth,
      fundamentalWave,
      carrierWave,
      0x00,
      bufferTime,
      0x00,
      duration,
      0x00,
      bufferTime,
      0x00,
      interval,
      valid,
      0x0A
    ];
    try {
      await ConnectManager
          .getInstance()
          .characteristic
          ?.write(param,
          withoutResponse: ConnectManager
              .getInstance()
              .characteristic!
              .properties
              .writeWithoutResponse);
      callBackTenWriteStatus(true);
    } catch (e) {
      if (kDebugMode) {
        print("Write Error:");
      }
      callBackTenWriteStatus(false);
    }
  }

  /// Управление устройством (старт/стоп/пауза/продолжение)
  static Future<void> controlDevice(
    TenControlDeviceType type,
    CallBackTenWriteStatus callBackTenWriteStatus,
  ) async {
    int byte;
    switch (type) {
      case TenControlDeviceType.start:
        byte = 0x02;
        break;
      case TenControlDeviceType.end:
        byte = 0x03;
        break;
      case TenControlDeviceType.pause:
        byte = 0x04;
        break;
      case TenControlDeviceType.continues:
        byte = 0x05;
        break;
    }

    int valid = (0x3B + 0x00 + 0x07 + 0x00 + byte) & 0xff;
    List<int> bytes = [0x3B, 0x00, 0x07, 0x00, byte, valid, 0x0A];

    try {
      await ConnectManager.getInstance().characteristic?.write(
        bytes,
        withoutResponse: ConnectManager.getInstance()
            .characteristic!
            .properties
            .writeWithoutResponse,
      );
      callBackTenWriteStatus(true);
    } catch (e) {
      if (kDebugMode) print("Write Error:");
      callBackTenWriteStatus(false);
    }
  }

  /// Отправка Амплитуды каналов
  /// максимум 100
  static Future<void> sendStrength(
    List<int> strength,
    CallBackTenWriteStatus callBackTenWriteStatus,
  ) async {
    List<int> bytes = [0x3B, 0x00, 0x11, 0x00, 0x07];
    int sum = bytes.reduce((value, element) => value + element);
    for (var element in strength) {
      sum += element;
      bytes.add(element);
    }
    int valid = sum & 0xff;
    bytes.add(valid);
    bytes.add(0x0A);

    try {
      await ConnectManager.getInstance().characteristic?.write(
        bytes,
        withoutResponse: ConnectManager.getInstance()
            .characteristic!
            .properties
            .writeWithoutResponse,
      );
      callBackTenWriteStatus(true);
    } catch (e) {
      if (kDebugMode) print("Write Error:");
      callBackTenWriteStatus(false);
    }
  }

  /// Получение заряда устройства
  static Future<void> getPower(CallBackPower callBackPower) async {
    ConnectManager.getInstance().powerTenEventBus.on<TenDevicePower>().listen((
      event,
    ) {
      callBackPower(event.percent > 0, event);
    });

    int valid = (0x3B + 0x00 + 0x07 + 0x00 + 0x0a) & 0xff;
    List<int> bytes = [0x3B, 0x00, 0x07, 0x00, 0x0a, valid, 0x0A];

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
      callBackPower(false, TenDevicePower());
    }
  }

  /// Выключение устройства
  static Future<void> closeDevice(
    CallBackTenWriteStatus callBackTenWriteStatus,
  ) async {
    int valid = (0x3B + 0x00 + 0x07 + 0x00 + 0x0e) & 0xff;
    List<int> bytes = [0x3B, 0x00, 0x07, 0x00, 0x0e, valid, 0x0A];

    try {
      await ConnectManager.getInstance().characteristic?.write(
        bytes,
        withoutResponse: ConnectManager.getInstance()
            .characteristic!
            .properties
            .writeWithoutResponse,
      );
      callBackTenWriteStatus(true);
    } catch (e) {
      if (kDebugMode) print("Write Error:");
      callBackTenWriteStatus(false);
    }
  }

}
