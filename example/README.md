# Boundary Guard Example

A Flutter example application demonstrating the usage of the `boundary_guard` package for monitoring geofence boundaries and displaying location-based messages.

## Getting Started

This project is a starting point for integrating the `boundary_guard` package into a Flutter application. It shows how to track a device's location, check if it is within a geofence, and display messages when the device moves outside the boundary.

### Installation

1. **Clone or Set Up the Project**:
   Ensure you have the `boundary_guard` package set up in the parent directory (`../`). If not, add it to your `pubspec.yaml` or use the local path.

   ```yaml
   dependencies:
     boundary_guard:
       path: ../
   ```

2. **Add Dependencies**:
   Update the `pubspec.yaml` in the `example` directory to include the necessary dependencies:

   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     boundary_guard:
       path: ../
     geolocator: ^14.0.2
     permission_handler: ^12.0.1
   ```

3. **Install Dependencies**:
   Run the following command in the `example` directory:

   ```bash
   flutter pub get
   ```

### Usage

The example app provides a simple UI with buttons to:
- Start tracking a device's location within a geofence.
- Check if the device is outside the geofence.
- Stop tracking.

Messages are displayed via SnackBars when the device moves outside the geofence or encounters errors (e.g., permission issues).

### Example Code

Below is the main code for the example app, located in `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:boundary_guard/boundary_guard.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const BoundaryGuardExample());
}

class BoundaryGuardExample extends StatefulWidget {
  const BoundaryGuardExample({super.key});

  @override
  _BoundaryGuardExampleState createState() => _BoundaryGuardExampleState();
}

class _BoundaryGuardExampleState extends State<BoundaryGuardExample> {
  final boundaryGuard = BoundaryGuard(
    onUpdate: (position, isOutsideBoundary, message) {
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
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
                    1000.0, // 1km radius
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
```

### Running the Example

1. Navigate to the `example` directory:

   ```bash
   cd example
   ```

2. Run the app:

   ```bash
   flutter run
   ```

3. Test the functionality:
    - Press "Start Tracking" to begin monitoring with a 1km radius around the reference point (San Francisco coordinates: 37.7749, -122.4194).
    - Press "Check Boundary" to manually verify if the device is outside the geofence.
    - Press "Stop Tracking" to end monitoring.
    - Messages (e.g., "You are outside the allowed boundary of 1 km") will appear as SnackBars.

### Additional Information

- **Dependencies**: The example relies on `boundary_guard`, `geolocator`, and `permission_handler`. Ensure these are correctly set up.
- **Permissions**: The app requests location permissions at runtime. Ensure location services are enabled on the device.
- **Resources**:
    - For more details on `boundary_guard`, see the [package README](../README.md).
    - For Flutter development, check the [Flutter documentation](https://docs.flutter.dev/), which offers tutorials, samples, and API references.

## License

MIT License. See the [LICENSE](../LICENSE) file for details.
