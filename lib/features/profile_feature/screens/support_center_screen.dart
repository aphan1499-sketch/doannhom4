import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'support_chat_screen.dart';

class SupportCenterScreen extends StatelessWidget {
  const SupportCenterScreen({super.key});

  Widget _buildCardWrapper(
    BuildContext context, {
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(color: Colors.white.withOpacity(0.05))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      endIndent: 16,
      color: isDark
          ? Colors.white.withOpacity(0.06)
          : Colors.grey.withOpacity(0.1),
    );
  }

  Widget _buildSupportTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text(
          'Hỗ trợ khách hàng',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 1. Top Illustration
            Center(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.headset_mic_outlined,
                      size: 64,
                      color: Colors.orange,
                    ),
                  ),
                  Text(
                    'Xin chào!\nChúng tôi có thể giúp gì cho bạn?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Chọn một phương thức liên hệ bên dưới để nhận trợ giúp nhé!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 2. Support Card Group
            _buildCardWrapper(
              context,
              children: [
                _buildSupportTile(
                  context,
                  icon: Icons.smart_toy_outlined,
                  iconColor: Colors.blue,
                  title: 'Trò chuyện với Trợ lý ảo AI',
                  subtitle: 'Hỗ trợ 24/7 về lịch chiếu & giá vé',
                  trailing: Icon(
                    Icons.chevron_right,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  onTap: () {
                    Get.to(() => const SupportChatScreen());
                  },
                ),
                _buildDivider(context),
                _buildSupportTile(
                  context,
                  icon: Icons.phone_in_talk_outlined,
                  iconColor: Colors.green,
                  title: 'Tổng đài CSKH',
                  subtitle: '1900 1234 (8:00 - 22:00)',
                  trailing: const Icon(
                    Icons.call,
                    color: Colors.green,
                    size: 20,
                  ),
                  onTap: () {
                    Get.snackbar(
                      'Đang gọi',
                      'Đang kết nối tới tổng đài hỗ trợ...',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  },
                ),
                _buildDivider(context),
                _buildSupportTile(
                  context,
                  icon: Icons.email_outlined,
                  iconColor: Colors.orange,
                  title: 'Gửi email hỗ trợ',
                  subtitle: 'support@xemphim.vn',
                  trailing: const Icon(
                    Icons.send,
                    color: Colors.orange,
                    size: 20,
                  ),
                  onTap: () {
                    Get.snackbar(
                      'Mở Email',
                      'Đang chuyển hướng sang ứng dụng Mail...',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.black.withOpacity(0.7),
                      colorText: Colors.white,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
