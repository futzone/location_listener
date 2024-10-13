import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:location_app/core/database/database_services.dart';
import 'package:location_app/core/models/custom_location_model.dart';
import 'package:location_app/core/services/method_type.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer timer;
  CustomLocationData data = CustomLocationData(totalDistance: 0, initialMethod: MethodType.unknown, speed: 0, totalTimes: 0);

  Future<void> permissionStatus() async {
    final status = await Permission.locationAlways.status;
    if (!status.isGranted) {
      bool granted = await Permission.locationAlways.request().isGranted;
      if (!granted) {
        log("Permission not granted");
        return;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    permissionStatus();  // Ensure permissions first

    timer = Timer.periodic(const Duration(milliseconds: 1200), (timer) async {
      CustomLocationData newData = await DatabaseServices().getLocalData();
      setState(() {
        data = newData;
        if (newData.initialMethod == MethodType.pause) {
          data.totalTimes = newData.totalTimes + (DateTime.now().difference(newData.pausedTime!)).inSeconds;
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Location Listener"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bosib o'tilgan umumiy masofa: ${(data.totalDistance / 1000).toStringAsFixed(2)} km",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Umumiy kutish vaqti: ${data.totalTimes ~/ 3600} soat. ${(data.totalTimes % 3600) ~/ 60} min. ${(data.totalTimes % 3600) % 60} s",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Tezlik: ${data.speed.toStringAsFixed(2)} m/s",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Yangilangan vaqti: ${data.updatedAt.toString().split(" ").last} da",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Vazifa statusi: ${data.initialMethod.name}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: data.initialMethod == MethodType.start ? Colors.blue : Colors.black,
                  ),
                  onPressed: () async {
                    if (data.initialMethod != MethodType.start) {
                      await changeStatus(MethodType.start);
                    }
                  },
                  child: const Text("Boshlash"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: data.initialMethod == MethodType.stop ? Colors.blue : Colors.black,
                  ),
                  onPressed: () async {
                    if (data.initialMethod != MethodType.stop) {
                      await changeStatus(MethodType.stop);
                    }
                  },
                  child: const Text("To'xtatish"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: data.initialMethod == MethodType.pause ? Colors.blue : Colors.black,
                  ),
                  onPressed: () async {
                    if (data.initialMethod != MethodType.pause) {
                      await changeStatus(MethodType.pause);
                    }
                  },
                  child: const Text("Kutish"),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> changeStatus(MethodType type) async {
    showLoadingDialog(context);
    await DatabaseServices().change(methodType: type);
    closeDialog();
  }

  showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  void closeDialog() async {
    Future.delayed(const Duration(milliseconds: 1000), () {
      Navigator.pop(context);
    });
  }
}
