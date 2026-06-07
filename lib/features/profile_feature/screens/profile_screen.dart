import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'account_info_screen.dart';
import 'change_password_screen.dart';
import 'device_management_screen.dart';
import 'login_screen.dart';
import 'manage_payment_methods_screen.dart';
import 'privacy_policy_screen.dart';
import 'support_center_screen.dart';
import 'transaction_history_screen.dart';
import 'vip_package_screen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final AuthController authController = Get.isRegistered<AuthController>()
      ? Get.find<AuthController>()
      : Get.put(AuthController());

  static const Color _red = Color(0xFFE52D27);

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _background(BuildContext context) =>
      _isDark(context) ? const Color(0xFF0B0B0C) : const Color(0xFFF6F6F7);

  Color _card(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1C1C1E) : Colors.white;

  Color _primaryText(BuildContext context) =>
      _isDark(context) ? Colors.white : const Color(0xFF171717);

  Color _secondaryText(BuildContext context) =>
      _isDark(context) ? Colors.grey.shade500 : Colors.grey.shade600;

  Color _line(BuildContext context) => _isDark(context)
      ? Colors.white.withOpacity(0.06)
      : Colors.black.withOpacity(0.06);

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }

  Widget _avatarImage(String source, String initials, double size) {
    final fallback = Center(
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.32,
          fontWeight: FontWeight.w900,
        ),
      ),
    );

    if (source.startsWith('http')) {
      return Image.network(
        source,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }

    return Image.asset(
      source,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }

  Widget _avatar(double size) {
    return Obx(() {
      final initials = _initials(authController.currentUser.value);
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFE52D27), Color(0xFFB31217)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipOval(
          child: _avatarImage(authController.userAvatar.value, initials, size),
        ),
      );
    });
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 22, 4, 10),
      child: Text(
        title,
        style: TextStyle(
          color: _secondaryText(context),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _menuCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: _card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line(context)),
        boxShadow: [
          if (!_isDark(context))
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider(BuildContext context) {
    return Divider(height: 1, indent: 68, endIndent: 16, color: _line(context));
  }

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    Color iconColor = _red,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 21),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _primaryText(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _secondaryText(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: _secondaryText(context),
                  size: 16,
                ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
    Get.defaultDialog(
      title: 'Đăng xuất',
      middleText: 'Bạn có chắc muốn đăng xuất khỏi tài khoản hiện tại?',
      textCancel: 'Hủy',
      textConfirm: 'Đăng xuất',
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.grey[700],
      buttonColor: _red,
      radius: 14,
      onConfirm: () {
        Get.back();
        authController.logout();
      },
    );
  }

  Widget _guestView(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _card(context),
                  border: Border.all(color: _line(context)),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Colors.redAccent,
                  size: 52,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Bạn chưa đăng nhập',
                style: TextStyle(
                  color: _primaryText(context),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Đăng nhập để quản lý hồ sơ, thiết bị và lịch sử giao dịch.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _secondaryText(context), height: 1.4),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () => Get.to(() => const LoginScreen()),
                  icon: const Icon(Icons.login_rounded),
                  label: const Text(
                    'ĐI TỚI ĐĂNG NHẬP',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileView(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2C0B0C), Color(0xFFB31217)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.24),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Hồ sơ cá nhân',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              color: Colors.white,
                              size: 15,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Đã đăng nhập',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _avatar(104),
                  const SizedBox(height: 16),
                  Obx(
                    () => Text(
                      authController.currentUser.value,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Obx(
                    () => Text(
                      authController.userEmail.value,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white.withOpacity(0.76)),
                    ),
                  ),
                ],
              ),
            ),
            _sectionTitle(context, 'TÀI KHOẢN'),
            _menuCard(context, [
              _menuTile(
                context,
                icon: Icons.person_outline_rounded,
                title: 'Thông tin tài khoản',
                subtitle: 'Tên, email, số điện thoại, ngày sinh',
                onTap: () => Get.to(() => AccountInfoScreen()),
              ),
              _divider(context),
              _menuTile(
                context,
                icon: Icons.lock_outline_rounded,
                title: 'Đổi mật khẩu',
                subtitle: 'Cập nhật mật khẩu đăng nhập',
                onTap: () => Get.to(() => const ChangePasswordScreen()),
              ),
              _divider(context),
              _menuTile(
                context,
                icon: Icons.star_outline_rounded,
                iconColor: Colors.amber,
                title: 'Đăng ký Gói VIP Streaming',
                subtitle: 'Nâng cấp tài khoản xem phim Premium',
                onTap: () => Get.to(() => const VipPackageScreen()),
              ),
              _divider(context),
              _menuTile(
                context,
                icon: Icons.receipt_long_outlined,
                title: 'Lịch sử giao dịch',
                subtitle: 'Các thanh toán đã thực hiện',
                onTap: () => Get.to(() => const TransactionHistoryScreen()),
              ),
              _divider(context),
              _menuTile(
                context,
                icon: Icons.payment_outlined,
                title: 'Phương thức thanh toán',
                subtitle: 'Quản lý thẻ và ví đã liên kết',
                onTap: () => Get.to(() => const ManagePaymentMethodsScreen()),
              ),
            ]),
            _sectionTitle(context, 'CÀI ĐẶT'),
            _menuCard(context, [
              Obx(
                () => _menuTile(
                  context,
                  icon: authController.isDarkMode.value
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                  title: authController.isDarkMode.value
                      ? 'Giao diện tối'
                      : 'Giao diện sáng',
                  subtitle: authController.isDarkMode.value
                      ? 'Đang bật'
                      : 'Đang tắt',
                  trailing: Switch(
                    value: authController.isDarkMode.value,
                    activeThumbColor: Colors.redAccent,
                    onChanged: (_) => authController.toggleTheme(),
                  ),
                ),
              ),
              _divider(context),
              _menuTile(
                context,
                icon: Icons.devices_outlined,
                title: 'Quản lý thiết bị',
                subtitle: 'Đăng xuất thiết bị không sử dụng',
                onTap: () => Get.to(() => const DeviceManagementScreen()),
              ),
              _divider(context),
              _menuTile(
                context,
                icon: Icons.shield_outlined,
                title: 'Chính sách bảo vệ thông tin',
                subtitle: 'Quy định bảo mật dữ liệu người dùng',
                onTap: () => Get.to(() => const PrivacyPolicyScreen()),
              ),
              _divider(context),
              _menuTile(
                context,
                icon: Icons.headset_mic_outlined,
                title: 'Trung tâm hỗ trợ',
                subtitle: 'Liên hệ khi gặp sự cố tài khoản',
                onTap: () => Get.to(() => const SupportCenterScreen()),
              ),
            ]),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _confirmLogout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  'Đăng xuất',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: BorderSide(color: Colors.redAccent.withOpacity(0.45)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: _background(context),
        body: authController.isLoggedIn.value
            ? _profileView(context)
            : _guestView(context),
      ),
    );
  }
}
