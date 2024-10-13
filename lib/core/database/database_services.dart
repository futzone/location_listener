import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:location_app/core/models/custom_location_model.dart';
import 'package:location_app/core/services/method_type.dart';

class DatabaseServices {
  Future<String> change({MethodType? methodType, double? speed, int? time, double? distance}) async {
    final jsonData = jsonDecode(await _read() ?? '{}');
    CustomLocationData customLocationData = CustomLocationData.fromMap(jsonData);

    if (methodType != null) {
      if (methodType == MethodType.pause) {
        customLocationData.pausedTime = DateTime.now();
      }

      if (customLocationData.initialMethod == MethodType.pause && methodType == MethodType.start && customLocationData.pausedTime != null) {
        int pausedTime = DateTime.now().difference(customLocationData.pausedTime!).inSeconds;
        customLocationData.totalTimes += pausedTime;
      }
      customLocationData.initialMethod = methodType;
    }
    if (speed != null) customLocationData.speed = speed;
    if (time != null) customLocationData.totalTimes = time;
    if (distance != null) customLocationData.totalDistance += distance;

    final encoded = jsonEncode(customLocationData.toMap());
    await _write(encoded);
    log('Total distance changed: ${customLocationData.totalDistance}');
    log('Method type changed: ${customLocationData.initialMethod}');
    return encoded;
  }

  Future<void> init() async {
    final oldData = await _read();
    if (oldData != null) return;

    CustomLocationData customLocationData = CustomLocationData(totalDistance: 0, initialMethod: MethodType.start, speed: 0, totalTimes: 0);

    await _write(jsonEncode(customLocationData.toMap()));
    log("Saved: ${customLocationData.initialMethod}");
  }

  Future<void> clear() async {
    CustomLocationData customLocationData = CustomLocationData(totalDistance: 0, initialMethod: MethodType.unknown, speed: 0, totalTimes: 0);
    await _write(jsonEncode(customLocationData.toMap()));
  }

  Future<CustomLocationData> getLocalData() async {
    final oldData = await _read();
    final jsonData = jsonDecode(oldData ?? '{}');
    CustomLocationData customLocationData = CustomLocationData.fromMap(jsonData);
    return customLocationData;
  }
}

Future<void> _write(String data) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/info.txt');
  await file.writeAsString(data, mode: FileMode.write).then((value) => log('saved'));
}

Future<String?> _read() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/info.txt');
    String content = await file.readAsString();
    return content;
  } catch (e) {
    return null;
  }
}
