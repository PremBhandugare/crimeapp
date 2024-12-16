import 'package:flutter/material.dart';
import 'package:shake/shake.dart';

class EmergencyShakeDetector {
  final BuildContext context;
  final VoidCallback onEmergencyTriggered;

  ShakeDetector? _shakeDetector;

  EmergencyShakeDetector({
    required this.context, 
    required this.onEmergencyTriggered
  });

  void initializeShakeDetector() {
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shake detected!')),
        );

        // Trigger emergency after specific shake count
        if (_shakeDetector!.mShakeCount == 2) {
          onEmergencyTriggered();
        }
      },
      minimumShakeCount: 2,
      shakeSlopTimeMS: 500,
      shakeCountResetTime: 20000,
      shakeThresholdGravity: 2.7,
    );
  }

  void dispose() {
    _shakeDetector?.stopListening();
  }
}