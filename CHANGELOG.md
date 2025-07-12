# Changelog

## [Unreleased]
### Added
- Initial support for location permissions in Android (`ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`) and iOS (`NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysUsageDescription`).
- Runtime permission request guidelines for Android 6.0+.

### Changed
- Updated documentation to include background location permission (`ACCESS_BACKGROUND_LOCATION`) for Android 10+.
- Clarified iOS permission descriptions for better user understanding.

### Fixed
- Corrected typo in manifest permission example formatting.

## [1.0.1] - 2025-07-12
### Added
- Comprehensive Dartdoc comments for all public APIs to enhance documentation for pub.dev.
- Unit tests in `test/boundary_guard_test.dart` to improve code health and pub points.
- `analysis_options.yaml` with strict lint rules to ensure code quality.
- Platform-specific configurations in `pubspec.yaml` for Android and iOS support.
- iOS `Info.plist` entries for location permissions in the example app.

### Changed
- Replaced deprecated `desiredAccuracy` parameter with `locationSettings` using `LocationSettings` in `Geolocator.getCurrentPosition` and `Geolocator.getPositionStream` to resolve deprecation warnings.
- Updated `README.md` with detailed API documentation and usage examples.

### Fixed
- Addressed deprecation warnings in `geolocator` API usage for better compatibility.

## [1.0.0] - 2025-07-12
### Added
- First release with basic app functionality.
- Initial manifest file setup for Android and iOS.

### Notes
- Initial release date aligns with project kickoff on July 12, 2025.
