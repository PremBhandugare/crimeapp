import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestSmsPermission() async {
    return await Permission.sms.request().isGranted;
  }

  Future<bool> isSmsPermissionGranted() async {
    return await Permission.sms.status.isGranted;
  }

  Future<bool> requestNotificationPermission() async {
    return await Permission.notification.request().isGranted;
  }
}