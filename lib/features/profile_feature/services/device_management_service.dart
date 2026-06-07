import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DeviceManagementService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<String?> getCurrentDeviceId() async {
    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.id;
    }
    if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
      return iosInfo.identifierForVendor;
    }
    return null;
  }

  /// Synchronizes the current device information and FCM token to Firestore
  /// under the path users/{uid}/devices/{deviceId} post-login.
  Future<void> syncDeviceData() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        print(
          "[DeviceManagementService] Sync aborted: No user is currently signed in.",
        );
        return;
      }

      final String uid = user.uid;
      String? deviceId;
      String? deviceName;
      String? os;

      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        deviceId = await getCurrentDeviceId();
        deviceName = androidInfo
            .model; // e.g. "Pixel 6 Pro" or "Android SDK built for x86"
        os =
            "Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})";
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        deviceId = await getCurrentDeviceId();
        deviceName = iosInfo.name; // e.g. "iPhone 13 Pro"
        os = "iOS ${iosInfo.systemVersion}";
      } else {
        print("[DeviceManagementService] Sync aborted: Unsupported platform.");
        return;
      }

      if (deviceId == null || deviceId.isEmpty) {
        print(
          "[DeviceManagementService] Sync aborted: Unique device ID could not be determined.",
        );
        return;
      }

      // Fetch FCM Token with error handling so it does not block the sync process
      String? fcmToken;
      try {
        fcmToken = await _firebaseMessaging.getToken();
      } catch (e) {
        print(
          "[DeviceManagementService] Warning: Could not retrieve FCM token: $e",
        );
      }

      final Map<String, dynamic> deviceData = {
        'deviceName': deviceName,
        'os': os,
        'fcmToken': fcmToken,
        'lastLogin': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      // Firestore Path: users/{uid}/devices/{deviceId}
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('devices')
          .doc(deviceId)
          .set(deviceData, SetOptions(merge: true));

      print(
        "[DeviceManagementService] Successfully synchronized device info for device: $deviceId, user: $uid",
      );
    } catch (e) {
      print(
        "[DeviceManagementService] Exception occurred during device data sync: $e",
      );
    }
  }

  /// Marks the current device as inactive in Firestore when the user logs out.
  /// Must be called BEFORE FirebaseAuth.instance.signOut() is executed.
  Future<void> logOutDevice() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        print(
          "[DeviceManagementService] Logout sync aborted: No user is currently signed in.",
        );
        return;
      }

      final String uid = user.uid;
      String? deviceId = await getCurrentDeviceId();

      if (deviceId == null || deviceId.isEmpty) {
        print(
          "[DeviceManagementService] Logout sync aborted: Device ID could not be determined.",
        );
        return;
      }

      // Firestore Path: users/{uid}/devices/{deviceId}
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('devices')
          .doc(deviceId)
          .update({'isActive': false});

      print(
        "[DeviceManagementService] Successfully marked device: $deviceId as inactive in Firestore.",
      );
    } catch (e) {
      print(
        "[DeviceManagementService] Exception occurred during device logout sync: $e",
      );
    }
  }
}
