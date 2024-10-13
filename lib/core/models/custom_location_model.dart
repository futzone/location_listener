import 'package:location_app/core/services/method_type.dart';

class CustomLocationData {
  double speed;
  int totalTimes;
  double totalDistance;
  MethodType initialMethod;
  DateTime? updatedAt;
  DateTime? pausedTime;

  CustomLocationData({
    required this.totalDistance,
    required this.initialMethod,
    required this.speed,
    required this.totalTimes,
    this.updatedAt,
    this.pausedTime,
  });

  factory CustomLocationData.fromMap(Map<String, dynamic> data) {
    MethodType? methodType;
    if (data['initialMethod'] == MethodType.unknown.name) methodType = MethodType.unknown;
    if (data['initialMethod'] == MethodType.stop.name) methodType = MethodType.stop;
    if (data['initialMethod'] == MethodType.start.name) methodType = MethodType.start;
    if (data['initialMethod'] == MethodType.pause.name) methodType = MethodType.pause;

    return CustomLocationData(
      totalDistance: data['totalDistance'] ?? 0,
      initialMethod: methodType ?? MethodType.unknown,
      speed: data['speed'] ?? 0,
      totalTimes: data['totalTimes'] ?? 0,
      updatedAt: DateTime.tryParse(data['updatedAt']??''),
      pausedTime: DateTime.tryParse( data['pausedTime']??''),
    );
  }

  toMap() => {
        "totalDistance": totalDistance,
        "totalTimes": totalTimes,
        "speed": speed,
        "pausedTime": pausedTime?.toString(),
        "initialMethod": initialMethod.name,
        "updatedAt": DateTime.now().toString()
      };
}
