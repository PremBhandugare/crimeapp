import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LocationService {
  Future<Position?> fetchCurrentLocation() async {
    try {
      final permissionStatus = await Geolocator.checkPermission();
      
      if (permissionStatus == LocationPermission.denied) {
        final newStatus = await Geolocator.requestPermission();
        if (newStatus == LocationPermission.denied || 
            newStatus == LocationPermission.deniedForever) {
          Fluttertoast.showToast(msg: "Location permission denied");
          return null;
        }
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true,
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching location: ${e.toString()}");
      return null;
    }
  }

  String generateGoogleMapsLink(double latitude, double longitude) {
    return 'https://www.google.com/maps?q=$latitude,$longitude';
  }
}