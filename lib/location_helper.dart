import 'dart:math';

class LocationHelper {
  static const double earthRadius = 6371e3; // in meters

  // Generate random location within a circle
  static Map<String, double> generateRandomLocation(double latitude, double longitude, double radius) {
    final Random random = Random();
    final double angle = 2 * pi * random.nextDouble();
    final double distance = sqrt(random.nextDouble()) * radius;

    final double deltaLatitude = distance * cos(angle) / earthRadius;
    final double deltaLongitude = distance * sin(angle) / (earthRadius * cos(latitude * pi / 180));

    final double newLatitude = latitude + deltaLatitude * 180 / pi;
    final double newLongitude = longitude + deltaLongitude * 180 / pi;

    return {
      'latitude': newLatitude,
      'longitude': newLongitude,
    };
  }
}
