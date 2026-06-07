import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class DeviceManagementScreen extends StatefulWidget {
  const DeviceManagementScreen({super.key});

  @override
  State<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen> {
  final AuthController authController = Get.find<AuthController>();

  static const Color _background = Color(0xFF0B0B0C);
  static const Color _card = Color(0xFF1C1C1E);
  static const Color _blue = Color(0xFF2979FF);

  @override
  void initState() {
    super.initState();
    authController.loadActiveDevices();
  }

  String _label(String device) => device.split('||').first;

  bool _isCurrent(String device) {
    final label = _label(device);
    return label.contains('Thiết bị này') ||
        label.contains('Thiáº¿t bá»‹ nÃ y');
  }

  bool _canRemove(String device) =>
      !_isCurrent(device) && device.contains('||');

  Widget _infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF2979FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(0.24),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.security_rounded, color: Colors.white, size: 30),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thiết bị đăng nhập',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Kiểm tra và đăng xuất những thiết bị không còn sử dụng.',
                  style: TextStyle(color: Colors.white70, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Icon(Icons.devices_other_outlined, color: Colors.grey[600], size: 42),
          const SizedBox(height: 12),
          const Text(
            'Không có thiết bị',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Danh sách sẽ xuất hiện sau khi hệ thống đồng bộ đăng nhập.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _deviceTile(String device) {
    final current = _isCurrent(device);
    final removable = _canRemove(device);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: current
              ? Colors.greenAccent.withOpacity(0.26)
              : Colors.white.withOpacity(0.04),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (current ? Colors.greenAccent : _blue).withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              current ? Icons.phone_android_rounded : Icons.devices_rounded,
              color: current ? Colors.greenAccent : _blue,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _label(device),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  current
                      ? 'Đang hoạt động trên thiết bị này'
                      : 'Thiết bị đang hoạt động',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (current)
            const Icon(Icons.check_circle, color: Colors.greenAccent, size: 24)
          else
            IconButton(
              onPressed: removable
                  ? () {
                      Get.defaultDialog(
                        title: 'Đăng xuất thiết bị',
                        middleText:
                            'Bạn muốn đăng xuất tài khoản khỏi thiết bị này?',
                        textCancel: 'Hủy',
                        textConfirm: 'Đăng xuất',
                        confirmTextColor: Colors.white,
                        cancelTextColor: Colors.grey[700],
                        buttonColor: Colors.redAccent,
                        radius: 14,
                        onConfirm: () async {
                          await authController.removeDevice(device);
                          Get.back();
                        },
                      );
                    }
                  : null,
              icon: Icon(
                Icons.logout_rounded,
                color: removable ? Colors.redAccent : Colors.grey[700],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('Quản lý thiết bị'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: authController.loadActiveDevices,
          color: _blue,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoCard(),
                const SizedBox(height: 22),
                Text(
                  'THIẾT BỊ ĐANG HOẠT ĐỘNG',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  if (authController.activeDevices.isEmpty) {
                    return _emptyState();
                  }
                  return Column(
                    children: authController.activeDevices
                        .map((device) => _deviceTile(device))
                        .toList(),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
