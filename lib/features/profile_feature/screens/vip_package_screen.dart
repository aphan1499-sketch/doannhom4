import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'payment_checkout_screen.dart';

class VipPackageScreen extends StatefulWidget {
  const VipPackageScreen({super.key});

  @override
  State<VipPackageScreen> createState() => _VipPackageScreenState();
}

class _VipPackageScreenState extends State<VipPackageScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _packages = [
    {
      'title': 'Monthly VIP',
      'price': 69000.0,
      'duration': '30 Ngày',
      'durationDays': 30,
      'saving': null,
      'badge': null,
      'gradient': [const Color(0xFF1F1C2C), const Color(0xFF928DAB)],
    },
    {
      'title': '6-Month VIP',
      'price': 349000.0,
      'duration': '180 Ngày',
      'durationDays': 180,
      'saving': 'Tiết kiệm 15%',
      'badge': 'PHỔ BIẾN',
      'gradient': [const Color(0xFFD82780), const Color(0xFFE11B74)],
    },
    {
      'title': 'Yearly VIP',
      'price': 599000.0,
      'duration': '365 Ngày',
      'durationDays': 365,
      'saving': 'Tiết kiệm 28%',
      'badge': 'TIẾT KIỆM NHẤT',
      'gradient': [const Color(0xFF0F2027), const Color(0xFF2C5364)],
    },
  ];

  final List<String> _benefits = [
    'Xem không giới hạn kho phim bom tấn chiếu rạp',
    'Chất lượng hình ảnh cực nét Full HD & 4K Ultra HD',
    'Âm thanh vòm Dolby Atmos sống động như tại rạp',
    'Hoàn toàn không chứa quảng cáo gây gián đoạn',
    'Hỗ trợ xem cùng lúc trên 3 thiết bị khác nhau',
    'Tải phim offline lưu trữ ngoại tuyến độ nét cao',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white70),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'HUIT CINEMA VIP',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            // Header Neon Title
            _buildNeonHeader(),
            const SizedBox(height: 24),

            // Packages list builder
            Column(
              children: List.generate(_packages.length, (index) {
                return _buildPackageCard(index);
              }),
            ),
            const SizedBox(height: 32),

            // Benefits checklist
            _buildBenefitsCard(),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomSheet: _buildBottomSubscribeBar(),
    );
  }

  Widget _buildNeonHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 14),
              SizedBox(width: 4),
              Text(
                'MỞ KHÓA TRẢI NGHIỆM ĐỈNH CAO',
                style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Nâng cấp Tài khoản VIP',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Trải nghiệm điện ảnh đỉnh cao không giới hạn',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildPackageCard(int index) {
    final package = _packages[index];
    final bool isSelected = _selectedIndex == index;
    final List<Color> colors = package['gradient'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected ? colors : [const Color(0xFF161618), const Color(0xFF161618)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.04),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.last.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Checked/glowing border highlight
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_off,
                    color: isSelected ? Colors.white : Colors.grey[600],
                    size: 22,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package['title'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[300],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Thời hạn: ${package['duration']}',
                          style: TextStyle(
                            color: isSelected ? Colors.white70 : Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${(package['price'] as double).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.amber,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (package['saving'] != null) ...[
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black26 : Colors.redAccent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            package['saving'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.redAccent,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Promotional badge in corner
            if (package['badge'] != null)
              Positioned(
                top: 0,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : colors.last,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    package['badge'],
                    style: TextStyle(
                      color: isSelected ? colors.last : Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF121214),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ĐẶC QUYỀN VIP MEMBERSHIP',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: _benefits.map((benefit) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, color: Colors.greenAccent, size: 16),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        benefit,
                        style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSubscribeBar() {
    final package = _packages[_selectedIndex];
    final double price = package['price'];

    return Container(
      color: const Color(0xFF0F0F10),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  package['title'],
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  '${price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              shadowColor: Colors.amber.withOpacity(0.3),
              elevation: 8,
            ),
            onPressed: () {
              // Construct a random unique booking orderId prefix for standard checkout screens compatibility
              final String mockOrderId = "VIP-${100000 + Random().nextInt(900000)}";
              Get.to(() => PaymentCheckoutScreen(
                    orderId: mockOrderId,
                    packageName: package['title'],
                    price: price,
                    durationDays: package['durationDays'] as int,
                  ));
            },
            child: const Text(
              'ĐĂNG KÝ NGAY',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
