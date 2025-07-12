import 'dart:async';
import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';

/// A service for monitoring geofence boundaries and providing location updates with messages.
class BoundaryGuard {
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _wasInsideBoundary = true;
  bool _hasAllPermissions = false;
  bool _isOperationInProgress = false;
  double? _radius;
  Position? _referencePosition;
  Position? _currentPosition;
  String? _message;
  bool _isOutsideBoundary = false;

  /// Callback to notify state changes (position, boundary status, or messages).
  final void Function(Position? position, bool isOutsideBoundary, String? message)?
  onUpdate;

  BoundaryGuard({this.onUpdate});

  /// Current position of the device.
  Position? get currentPosition => _currentPosition;

  /// Current boundary status (true if outside the geofence).
  bool get isOutsideBoundary => _isOutsideBoundary;

  /// Current message (e.g., boundary violation or error).
  String? get message => _message;

  /// Calculate distance using Haversine formula (in meters).
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000;
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    double lat1Rad = _degreesToRadians(lat1);
    double lat2Rad = _degreesToRadians(lat2);
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Check if a position is inside the geofence.
  bool _isInsideGeofence(double latitude, double longitude) {
    if (_radius == null || _referencePosition == null) return false;
    double distance = _calculateDistance(
      latitude,
      longitude,
      _referencePosition!.latitude,
      _referencePosition!.longitude,
    );
    return distance <= _radius!;
  }

  /// Check and request location permissions.
  Future<bool> _checkAndRequestPermissions() async {
    if (_isOperationInProgress) {
      _message = 'An operation is already in progress. Please wait.';
      onUpdate?.call(_currentPosition, _isOutsideBoundary, _message);
      return false;
    }

    _isOperationInProgress = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _message = 'Location services are disabled';
        onUpdate?.call(_currentPosition, _isOutsideBoundary, _message);
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _message = 'Location permission denied. Please grant the permission.';
          onUpdate?.call(_currentPosition, _isOutsideBoundary, _message);
          return false;
        } else if (permission == LocationPermission.deniedForever) {
          _message =
          'Location permission denied forever. Please enable in settings.';
          onUpdate?.call(_currentPosition, _isOutsideBoundary, _message);
          await Geolocator.openAppSettings();
          return false;
        }
      } else if (permission == LocationPermission.deniedForever) {
        _message =
        'Location permission denied forever. Please enable in settings.';
        onUpdate?.call(_currentPosition, _isOutsideBoundary, _message);
        await Geolocator.openAppSettings();
        return false;
      }

      _hasAllPermissions = true;
      return true;
    } finally {
      _isOperationInProgress = false;
    }
  }

  /// Start tracking location with respect to a geofence.
  Future<void> startTracking(double radius, Position referencePosition) async {
    if (_isOperationInProgress) {
      _message = 'A tracking operation is already in progress. Please wait.';
      onUpdate?.call(_currentPosition, _isOutsideBoundary, _message);
      return;
    }

    _isOperationInProgress = true;
    try {
      _radius = radius;
      _referencePosition = referencePosition;
      _isOutsideBoundary = false;

      bool permissionsGranted = await _checkAndRequestPermissions();
      if (!permissionsGranted) {
        return;
      }

      try {
        _currentPosition = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        _wasInsideBoundary = _isInsideGeofence(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
        _isOutsideBoundary = !_wasInsideBoundary;
        _message = _wasInsideBoundary
            ? null
            : 'You are already outside the allowed boundary of ${radius / 1000} km';
        onUpdate?.call(_currentPosition, _isOutsideBoundary, _message);
      } catch (e) {
        _message = 'Error determining initial position: $e';
        onUpdate?.call(_currentPosition, _isOutsideBoundary, _message);
        return;
      }

      await _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      ).listen((Position position) {
        _updatePosition(position);
      }, onError: (error) {
        _message = 'Error in location stream: $error';
        onUpdate?.call(_currentPosition, _isOutsideBoundary, _message);
      });
    } catch (e) {
      _message = 'Error starting boundary tracking: $e';
      onUpdate?.call(_currentPosition, _isOutsideBoundary, _message);
    } finally {
      _isOperationInProgress = false;
    }
  }

  /// Check if the current position is outside the geofence.
  Future<void> checkIfOutsideBoundary() async {
    try {
      if (_radius == null || _referencePosition == null) {
        _message = 'Boundary parameters not set. Start tracking first.';
        _isOutsideBoundary = true;
        onUpdate?.call(_currentPosition, _isOutsideBoundary, _message);
        return;
      }

      if (!_hasAllPermissions) {
        bool permissionsGranted = await _checkAndRequestPermissions();
        if (!permissionsGranted) {
          _isOutsideBoundary = true;
          onUpdate?.call(_currentPosition, _isOutsideBoundary, _message);
          return;
        }
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Timeout getting current position');
        },
      );

      bool isInside = _isInsideGeofence(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      _isOutsideBoundary = !isInside;
      _message = isInside
          ? null
          : 'You are outside the allowed boundary of ${_radius! / 1000} km';
      _wasInsideBoundary = isInside;
      onUpdate?.call(_currentPosition, _isOutsideBoundary, _message);
    } catch (e) {
      _message = 'Error checking boundary: $e';
      _isOutsideBoundary = true;
      onUpdate?.call(_currentPosition, _isOutsideBoundary, _message);
    }
  }

  /// Update position and check boundary.
  void _updatePosition(Position position) {
    if (_radius == null || _referencePosition == null) {
      _message = 'Boundary parameters not set';
      onUpdate?.call(_currentPosition, _isOutsideBoundary, _message);
      return;
    }

    _currentPosition = position;
    bool isInside = _isInsideGeofence(
      position.latitude,
      position.longitude,
    );

    if (_wasInsideBoundary && !isInside) {
      _isOutsideBoundary = true;
      _message =
      'You have moved outside the allowed boundary of ${_radius! / 1000} km';
      _wasInsideBoundary = false;
    } else if (!_wasInsideBoundary && isInside) {
      _isOutsideBoundary = false;
      _message = null;
      _wasInsideBoundary = true;
    }

    onUpdate?.call(_currentPosition, _isOutsideBoundary, _message);
  }

  /// Stop tracking location.
  Future<void> stopTracking() async {
    if (_isOperationInProgress) {
      _message = 'A tracking operation is in progress. Please wait.';
      onUpdate?.call(_currentPosition, _isOutsideBoundary, _message);
      return;
    }

    _isOperationInProgress = true;
    try {
      await _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;
      _currentPosition = null;
      _radius = null;
      _referencePosition = null;
      _isOutsideBoundary = false;
      _message = null;
      onUpdate?.call(_currentPosition, _isOutsideBoundary, _message);
    } finally {
      _isOperationInProgress = false;
    }
  }

  /// Clean up resources.
  Future<void> dispose() async {
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }
}
