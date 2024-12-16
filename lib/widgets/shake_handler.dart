import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shake/shake.dart';
import 'package:location/location.dart';

class ShakeHandler {
  final Function(String message) onSendSms;
  final VoidCallback onAccidentalShake;

  ShakeHandler({
    required this.onSendSms,
    required this.onAccidentalShake,
  });

  late ShakeDetector _shakeDetector;
  final Location _location = Location();

  List<Map<String, dynamic>> RcrimeData = [];
  List<dynamic>? emergencyContacts;

  // Initialize the shake detection
  void initializeShakeDetection() {
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: () async {
        final locationData = await fetchLocation();
        if (locationData != null) {
          final message =
              "Emergency! Current location: https://maps.google.com/?q=${locationData.latitude},${locationData.longitude}";
          sendSms(message);
        } else {
          print('Could not fetch location.');
        }
        onAccidentalShake();
      },
    );
  }

  // Fetch the current location of the user
  Future<LocationData?> fetchLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          return null;
        }
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return null;
        }
      }

      final locationData = await _location.getLocation();
      return locationData;
    } catch (e) {
      print('Error fetching location: $e');
      return null;
    }
  }

  // Fetch emergency contacts from Firestore
  Future<void> fetchEmergencyContacts() async {
    final user = FirebaseAuth.instance.currentUser;
    final repdoc = await FirebaseFirestore.instance.collection("report").get();
    RcrimeData = repdoc.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        emergencyContacts = data['emergencyNumber'] ?? [];
        Fluttertoast.showToast(msg: 'Data Fetched');
      }
    }
  }

  // Send the SMS with the given message
  void sendSms(String message) {
    onSendSms(message);
  }

  // Stop listening for shakes when no longer needed
  void dispose() {
    _shakeDetector.stopListening();
  }
}
