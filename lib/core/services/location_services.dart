import 'dart:async';
import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:location_app/core/database/database_services.dart';
import 'package:location_app/core/services/method_type.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationServices {
  bool? broken;

  static Future<void> handlePermissions() async {
    await _requestLocationPermission();
    await _defaultCreate();
  }

  static Future<void> _requestLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission != LocationPermission.always) {
      await Permission.location.request();
      await Permission.locationAlways.request();
    }

    final serviceStatus = await Geolocator.isLocationServiceEnabled();
    if (!serviceStatus) await Geolocator.openLocationSettings();
  }

  static Future<void> onListenLocationChanges(Position position, Position current) async {
    DatabaseServices databaseServices = DatabaseServices();
    final initialValue = await databaseServices.getLocalData();

    log(initialValue.initialMethod.toString());
    if (current.accuracy > 10) return;
    if (initialValue.initialMethod == MethodType.stop || initialValue.initialMethod == MethodType.unknown) return;

    var distance = Geolocator.distanceBetween(position.latitude, position.longitude, current.latitude, current.longitude);
    await databaseServices.change(
      speed: position.speed,
      distance: initialValue.initialMethod == MethodType.pause ? null : distance,
      methodType: position.speed * 3.6 > 30 ? MethodType.start : null,
    );
  }

  static Future<void> _defaultCreate() async {
    DatabaseServices databaseServices = DatabaseServices();
    await databaseServices.init();
  }
}
