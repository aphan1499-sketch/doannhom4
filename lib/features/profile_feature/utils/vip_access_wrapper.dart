import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/vip_package_screen.dart';

class VipAccessWrapper {
  /// Core static utility to verify VIP Subscription before initiating movie streams
  static Future<void> checkVipAccess({
    required BuildContext context,
    required VoidCallback onPlay,
  }) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      Get.snackbar(
        'Yêu cầu đăng nhập',
        'Vui lòng đăng nhập tài khoản để xem các bộ phim đặc sắc.',
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }

    // Show instant micro loading dialog
    Get.dialog(
      const Center(
        child: Card(
          color: Color(0xFF1E1E1E),
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(color: Colors.amber),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      Get.back(); // Dismiss loading

      bool isVip = false;
      DateTime? expiryDate;

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          isVip = data['isVip'] ?? false;
          final String? expiryStr = data['vipExpiryDate'];
          if (expiryStr != null) {
            expiryDate = DateTime.tryParse(expiryStr);
          }
        }
      }

      // Check validation
      final bool hasActiveVip = isVip && expiryDate != null && expiryDate.isAfter(DateTime.now());

      if (hasActiveVip) {
        print("[VipAccess] Active VIP subscription confirmed. Expiry: $expiryDate");
        onPlay(); // Execute actual playback action
      } else {
        print("[VipAccess] User is not VIP or membership has expired.");
        _showUpgradeVipBottomSheet(context);
      }
    } catch (e) {
      Get.back(); // Dismiss loading
      Get.snackbar(
        'Lỗi kiểm tra quyền',
        'Không thể xác minh gói cước VIP: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  /// Stunning Dark Premium Movie Streaming bottom sheet
  static void _showUpgradeVipBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F0F10),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Elegant gold lock icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline, color: Colors.amber, size: 28),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Phim này chỉ dành cho VIP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Hãy nâng cấp lên tài khoản VIP để thưởng thức bộ phim bom tấn này cùng hàng ngàn đặc quyền xem phim Premium không quảng cáo!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                
                // CTA Action Upgrade button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Get.back(); // Close bottomsheet
                    Get.to(() => const VipPackageScreen()); // Open selection VIP Screen
                  },
                  child: const Text(
                    'Nâng cấp VIP ngay',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Close option
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text(
                    'Để sau',
                    style: TextStyle(color: Colors.white30, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
