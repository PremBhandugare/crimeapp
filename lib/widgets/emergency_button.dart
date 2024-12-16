import 'package:flutter/material.dart';

class EmergencyButton extends StatelessWidget {
  final VoidCallback onPressed;

  const EmergencyButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.red,
      onPressed: onPressed,
      child: CircleAvatar(
        backgroundColor: Colors.red,
        child: Text(
          'S.O.S', 
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}