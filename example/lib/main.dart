import 'package:flutter/material.dart';
import 'package:boundary_guard/boundary_guard.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final boundaryGuard = BoundaryGuard(
    onUpdate: (position, isOutsideBoundary, message) {
      print('Position: $position');
      print('Is Outside: $isOutsideBoundary');
      if (message != null) {
        print('Message: $message');
      }
    },
  );

  @override
  void dispose() {
    boundaryGuard.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Boundary Guard Example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await boundaryGuard.startTracking(
                    1000.0,
                    Position(
                      latitude: 37.7749,
                      longitude: -122.4194,
                      timestamp: DateTime.now(),
                      accuracy: 0,
                      altitude: 0,
                      heading: 0,
                      speed: 0,
                      speedAccuracy: 0,
                      altitudeAccuracy: 0,
                      headingAccuracy: 0,
                    ),
                  );
                },
                child: const Text('Start Tracking'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await boundaryGuard.checkIfOutsideBoundary();
                },
                child: const Text('Check Boundary'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await boundaryGuard.stopTracking();
                },
                child: const Text('Stop Tracking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
