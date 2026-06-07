import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Widget _buildCardWrapper(BuildContext context, {required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.05)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildPolicySection(BuildContext context, {
    required String number,
    required String title,
    required String content,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.teal, 
                  fontWeight: FontWeight.bold,
                  fontSize: 12
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold, 
                  color: isDark ? Colors.white : Colors.black87
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: TextStyle(
            fontSize: 14, 
            height: 1.6,
            color: isDark ? Colors.grey[400] : Colors.grey[700]
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Divider(
        height: 1,
        thickness: 1,
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.withOpacity(0.1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text(
          'Bảo vệ thông tin',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
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
                      color: Colors.teal.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined, 
                      size: 64, 
                      color: Colors.teal
                    ),
                  ),
                  Text(
                    'Cam kết bảo mật dữ liệu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Quyền riêng tư của bạn là ưu tiên hàng đầu của chúng tôi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // 2. Policy Card
            _buildCardWrapper(
              context,
              children: [
                _buildPolicySection(
                  context,
                  number: '01',
                  title: 'Thu thập thông tin',
                  content: 'Chúng tôi thu thập các thông tin cơ bản như tên, email và lịch sử xem phim để cá nhân hóa trải nghiệm của bạn. Quá trình này tuân thủ nghiêm ngặt các quy định về bảo mật dữ liệu.',
                ),
                _buildDivider(context),
                _buildPolicySection(
                  context,
                  number: '02',
                  title: 'Sử dụng dữ liệu',
                  content: 'Dữ liệu của bạn chỉ được sử dụng trong phạm vi ứng dụng để đề xuất phim, quản lý tài khoản và hỗ trợ kỹ thuật. Tuyệt đối không chia sẻ cho bên thứ ba vì mục đích thương mại.',
                ),
                _buildDivider(context),
                _buildPolicySection(
                  context,
                  number: '03',
                  title: 'Bảo mật thông tin',
                  content: 'Hệ thống sử dụng các phương thức lưu trữ an toàn (Local Storage) và mã hóa cơ bản để bảo vệ thông tin cá nhân của bạn khỏi các truy cập trái phép.',
                ),
                _buildDivider(context),
                _buildPolicySection(
                  context,
                  number: '04',
                  title: 'Quyền của người dùng',
                  content: 'Bạn có quyền yêu cầu xem, sửa đổi hoặc xóa toàn bộ dữ liệu cá nhân của mình bất kỳ lúc nào thông qua phần Cài đặt tài khoản trong ứng dụng.',
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