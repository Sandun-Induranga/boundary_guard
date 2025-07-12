# Boundary Guard

A Flutter package for monitoring geofence boundaries and providing real-time location updates with customizable messages.

## Getting Started

This package allows you to track a device's location relative to a geofence and receive messages when the device moves outside the boundary. It uses the Haversine formula for accurate distance calculations and handles location permissions seamlessly.

To get started, add `boundary_guard` to your project and follow the steps below.

### Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  boundary_guard: ^1.0.0
```

Then, run:

```bash
flutter pub get
```

### Prerequisites

Ensure you have the following dependencies in your `pubspec.yaml`:

- `geolocator: ^10.1.0`
- `permission_handler: ^11.0.0`

### Usage

1. **Initialize the BoundaryGuard**:
   Create an instance of `BoundaryGuard` with a callback to handle updates.

   ```dart
   import 'package:boundary_guard/boundary_guard.dart';

   final boundaryGuard = BoundaryGuard(
     onUpdate: (position, isOutsideBoundary, message) {
       if (message != null) {
         print('Message: $message');
       }
     },
   );
   ```

2. **Start Tracking**:
   Begin tracking with a radius (in meters) and a reference position.

   ```dart
   import 'package:geolocator/geolocator.dart';

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
   ```

3. **Check Boundary**:
   Manually check if the device is outside the geofence.

   ```dart
   await boundaryGuard.checkIfOutsideBoundary();
   ```

4. **Stop Tracking**:
   Stop tracking and clear resources.

   ```dart
   await boundaryGuard.stopTracking();
   ```

### Example

Below is a complete example of a Flutter app using `BoundaryGuard`:

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

## Additional Information

- **Features**:
    - Real-time location tracking and geofence boundary checking.
    - Handles location permissions and errors with user-friendly messages.
    - Lightweight with no dependency on state management frameworks.

- **API Reference**:
    - `startTracking(double radius, Position referencePosition)`: Starts geofence tracking.
    - `checkIfOutsideBoundary()`: Checks if the device is outside the geofence.
    - `stopTracking()`: Stops tracking and clears resources.
    - `dispose()`: Cleans up resources.
    - Properties: `currentPosition`, `isOutsideBoundary`, `message`.

For more details, view the [Boundary Guard documentation](https://github.com/Sandun-Induranga/boundary_guard) or the [Flutter documentation](https://docs.flutter.dev/).

## License

MIT License. See the [LICENSE](LICENSE) file for details.
