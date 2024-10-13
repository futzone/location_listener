import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_app/view/home.dart';
import 'core/services/location_services.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  Position? position;
  Geolocator.getPositionStream(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high)).listen((current) async {
    try {
      position ??= current;
      await LocationServices.onListenLocationChanges(position!, current);
      position = current;
    } catch (e) {
      log("Error in position stream: $e");
    }
  });
}

Future<void> initServices() async {
  log("Flutter background services initialized!");

  try {
    final service = FlutterBackgroundService();
    if (await service.isRunning()) return;
    await service.configure(
      iosConfiguration: IosConfiguration(),
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: false,
      ),
    );

    await service.startService();
  } catch (e) {
    log("InitServices error: $e");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocationServices.handlePermissions();
  await initServices();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Listener Demo',
      theme: ThemeData(useMaterial3: false),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
