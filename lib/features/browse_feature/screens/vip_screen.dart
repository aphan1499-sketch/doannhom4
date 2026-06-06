import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'vnpay_mock_screen.dart';

class VipScreen extends StatelessWidget {
  const VipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Nâng cấp VIP'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: Get.back,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Mở khóa trải nghiệm cao cấp',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Xem phim VIP, ưu tiên chất lượng phát và tận hưởng nội dung độc quyền.',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 18),
              _PremiumFeatureTile(
                icon: Icons.diamond_outlined,
                title: 'Nội dung VIP',
                subtitle: 'Mở khóa phim cao cấp và bom tấn mới.',
              ),
              _PremiumFeatureTile(
                icon: Icons.high_quality_rounded,
                title: 'Chất lượng 4K',
                subtitle: 'Trải nghiệm hình ảnh mượt mà, sắc nét hơn.',
              ),
              _PremiumFeatureTile(
                icon: Icons.offline_bolt_rounded,
                title: 'Không quảng cáo',
                subtitle: 'Thưởng thức phim mà không bị gián đoạn.',
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _PlanCard(
                      title: 'Tháng',
                      price: '50.000đ',
                      subtitle: 'Phù hợp thử nghiệm ngắn hạn',
                      onTap: () => Get.to(
                        VnpayMockScreen(planName: 'Tháng', price: '50.000đ'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PlanCard(
                      title: 'Năm',
                      price: '500.000đ',
                      subtitle: 'Tiết kiệm hơn với gói dài hạn',
                      highlighted: true,
                      onTap: () => Get.to(
                        VnpayMockScreen(planName: 'Năm', price: '500.000đ'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumFeatureTile extends StatelessWidget {
  const _PremiumFeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF171A22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: <Color>[Color(0xFFFDE68A), Color(0xFFF59E0B)],
              ),
            ),
            child: Icon(icon, color: const Color(0xFF111827)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.subtitle,
    required this.onTap,
    this.highlighted = false,
  });

  final String title;
  final String price;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF171A22),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: highlighted ? const Color(0xFFFBBF24) : Colors.white10,
            width: highlighted ? 1.4 : 1,
          ),
          boxShadow: highlighted
              ? const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x55FBBF24),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: const TextStyle(
                color: Color(0xFFFBBF24),
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                highlighted ? 'Khuyến nghị' : 'Chọn gói',
                style: TextStyle(
                  color: highlighted ? const Color(0xFFFBBF24) : Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
