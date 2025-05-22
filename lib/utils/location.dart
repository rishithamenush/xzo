import 'package:geolocator/geolocator.dart';
import 'dart:developer';

class LocationService {
  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        log('Location services are disabled');
        return null;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          log('Location permissions are denied');
          return null;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        log('Location permissions are permanently denied');
        return null;
      }

      // Get current position
      log('Getting current position...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      log('Current position: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e, stackTrace) {
      log('Error getting location: $e', error: e, stackTrace: stackTrace);
      return null;
    }
  }
} 