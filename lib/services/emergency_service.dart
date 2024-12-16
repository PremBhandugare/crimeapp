import 'package:background_sms/background_sms.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';


class EmergencyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<String>> fetchEmergencyContacts() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data();
          return List<String>.from(data?['emergencyNumber'] ?? []);
        }
      } catch (e) {
        Fluttertoast.showToast(msg: 'Error fetching emergency contacts');
      }
    }
    return [];
  }

  Future<bool> sendEmergencySMS({
    required List<String> contacts, 
    required String message
  }) async {
    bool allSent = true;
    for (var number in contacts) {
      final result = await BackgroundSms.sendMessage(
        phoneNumber: number, 
        message: message
      );
      
      if (result != SmsStatus.sent) {
        allSent = false;
        Fluttertoast.showToast(msg: 'Failed to send SMS to $number');
      }
    }
    return allSent;
  }
}