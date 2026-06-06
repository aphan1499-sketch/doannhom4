import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/search_controller.dart';

class VnpayMockScreen extends StatelessWidget {
  const VnpayMockScreen({
    super.key,
    required this.planName,
    required this.price,
  });

  final String planName;
  final String price;

  @override
  Widget build(BuildContext context) {
    final BrowseController controller = Get.find<BrowseController>();

    return Scaffold(
      backgroundColor: const Color(0xFF07111F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('VNPay Sandbox'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: Get.back),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF10253A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white10),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'VNPay',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Giao dịch thử nghiệm',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    _InfoRow(label: 'Mã giao dịch', value: 'TRIAL-VIP-2026'),
                    _InfoRow(
                      label: 'Order Info',
                      value: 'Nâng cấp VIP $planName',
                    ),
                    _InfoRow(label: 'Số tiền', value: price),
                    _InfoRow(label: 'Phương thức', value: 'Ví VNPay Sandbox'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Text(
                  'Lưu ý: Đây là mock portal dùng cho demo, không thực hiện thanh toán thật.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              const Spacer(),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.snackbar(
                          'Đã hủy',
                          'Giao dịch đã bị hủy.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF171A22),
                          colorText: Colors.white,
                        );
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Hủy giao dịch'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.setVipStatus(true);
                        Get.dialog(
                          AlertDialog(
                            backgroundColor: const Color(0xFF111827),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            title: const Text(
                              'Nâng cấp VIP thành công!',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              'Bạn đã được mở khóa nội dung VIP.',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          barrierDismissible: false,
                        );
                        Future.delayed(const Duration(milliseconds: 900), () {
                          if (Get.isDialogOpen ?? false) {
                            Get.back();
                          }
                          Get.back();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFBBF24),
                        foregroundColor: const Color(0xFF111827),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Xác nhận thành công'),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
