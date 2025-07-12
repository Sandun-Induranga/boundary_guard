import 'package:flutter_test/flutter_test.dart';
import 'package:boundary_guard/boundary_guard.dart';

void main() {
  test('BoundaryGuard initializes correctly', () {
    final boundaryGuard = BoundaryGuard();
    expect(boundaryGuard.currentPosition, isNull);
    expect(boundaryGuard.isOutsideBoundary, isFalse);
    expect(boundaryGuard.message, isNull);
  });
}
