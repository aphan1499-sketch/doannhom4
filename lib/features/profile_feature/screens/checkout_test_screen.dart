import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/payment_service.dart';
import 'payment_webview_screen.dart';

class CheckoutTestScreen extends StatefulWidget {
  const CheckoutTestScreen({super.key});

  @override
  State<CheckoutTestScreen> createState() => _CheckoutTestScreenState();
}

class _CheckoutTestScreenState extends State<CheckoutTestScreen> {
  final PaymentService _paymentService = PaymentService();
  PaymentMethod _selectedMethod = PaymentMethod.vnpay;
  bool _isLoading = false;

  // Mock booking detail details
  final String _orderId = "HUIT-${100000 + Random().nextInt(900000)}";
  final String _movieTitle = "Lật Mặt 7: Một Điều Ước";
  final String _showtime = "20:00 - Thứ Ba, HUIT Cinema Tân Phú";
  final String _seats = "F11, F12 (IMAX VIP)";
  final double _amount = 170000; // 170,000 VND

  /// Triggers checkout process
  Future<void> _handleCheckout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String? paymentUrl = await _paymentService.processCheckout(
        amount: _amount,
        orderId: _orderId,
        method: _selectedMethod,
        movieTitle: _movieTitle,
      );

      setState(() {
        _isLoading = false;
      });

      if (paymentUrl == null && _selectedMethod != PaymentMethod.vnpay) {
        _showStatusDialog(
          title: 'Lỗi khởi tạo',
          message: 'Không thể kết nối API cổng thanh toán Sandbox. Vui lòng kiểm tra lại cấu hình tệp .env.',
          isSuccess: false,
        );
        return;
      }

      if (_selectedMethod == PaymentMethod.vnpay) {
        // Open VNPay inside Native WebView Screen
        final bool? isSuccess = await Get.to<bool>(
          () => PaymentWebViewScreen(url: paymentUrl!, orderId: _orderId),
        );

        if (isSuccess == true) {
          _showStatusDialog(
            title: 'Thanh toán thành công',
            message: 'Đơn hàng $_orderId đã thanh toán thành công qua cổng VNPay Sandbox!',
            isSuccess: true,
          );
        } else {
          _showStatusDialog(
            title: 'Thanh toán thất bại',
            message: 'Đơn hàng $_orderId đã bị hủy hoặc gặp lỗi khi giao dịch qua VNPay Sandbox.',
            isSuccess: false,
          );
        }
      } else {
        // MoMo and ZaloPay App Redirect / App launch
        print("[CheckoutTest] Launching sandbox gateway URL: $paymentUrl");
        final bool launched = await _paymentService.launchPaymentLink(paymentUrl!);

        if (launched) {
          _showSandboxConfirmDialog(paymentUrl);
        } else {
          _showStatusDialog(
            title: 'Lỗi liên kết',
            message: 'Không thể mở liên kết thanh toán. URL: $paymentUrl',
            isSuccess: false,
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showStatusDialog(
        title: 'Lỗi hệ thống',
        message: 'Đã xảy ra lỗi ngoài ý muốn: $e',
        isSuccess: false,
      );
    }
  }

  /// Displays simulated callback confirm dialogue for MoMo/ZaloPay
  void _showSandboxConfirmDialog(String paymentUrl) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.amber, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Xác nhận Giao dịch',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hệ thống vừa chuyển hướng bạn đến cổng Sandbox MoMo/ZaloPay.',
              style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Text(
              'Vì đây là môi trường máy ảo kiểm thử (Sandbox), bạn có muốn giả lập kết quả phản hồi của cổng giao dịch ngay bây giờ không?',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Get.back();
              await _paymentService.updateBookingStatus(orderId: _orderId, isSuccess: false);
              _showStatusDialog(
                title: 'Giao dịch thất bại',
                message: 'Bạn đã chọn giả lập trạng thái thanh toán thất bại cho đơn hàng $_orderId.',
                isSuccess: false,
              );
            },
            child: const Text('Thất bại (Fail)', style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Get.back();
              await _paymentService.updateBookingStatus(orderId: _orderId, isSuccess: true);
              _showStatusDialog(
                title: 'Giao dịch thành công',
                message: 'Bạn đã giả lập thanh toán thành công cho đơn hàng $_orderId!',
                isSuccess: true,
              );
            },
            child: const Text('Thành công (Success)', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Final transaction outcome dialog
  void _showStatusDialog({
    required String title,
    required String message,
    required bool isSuccess,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Center(
          child: Column(
            children: [
              Icon(
                isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                color: isSuccess ? Colors.green : Colors.redAccent,
                size: 60,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.grey[300] : Colors.grey[600],
            fontSize: 14,
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSuccess ? Colors.green : Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Get.back(),
              child: const Text('Đóng', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Thanh Toán Sandbox',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Ticket Card Summary
                _buildTicketCard(isDark),
                const SizedBox(height: 24),

                // 2. Title Section
                Text(
                  'Chọn cổng thanh toán kiểm thử (Sandbox)',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // 3. Payment Method Selectors
                _buildPaymentTile(
                  method: PaymentMethod.momo,
                  title: 'Ví điện tử MoMo',
                  subtitle: 'Sandbox Testing Gateway',
                  logo: _buildMoMoLogo(),
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildPaymentTile(
                  method: PaymentMethod.zalopay,
                  title: 'Ví điện tử ZaloPay',
                  subtitle: 'Sandbox Testing Gateway',
                  logo: _buildZaloPayLogo(),
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildPaymentTile(
                  method: PaymentMethod.vnpay,
                  title: 'Cổng thanh toán VNPay',
                  subtitle: 'Hỗ trợ thẻ ATM, Visa, MasterCard',
                  logo: _buildVNPayLogo(),
                  isDark: isDark,
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),

          // 4. Fixed Bottom Checkout Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomCheckoutBar(isDark),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.redAccent),
                    SizedBox(height: 16),
                    Text(
                      'Đang xử lý chữ ký mật mã bảo mật...',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Premium Ticket Summary Card
  Widget _buildTicketCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
              ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
              : [Colors.white, const Color(0xFFF9F9FB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: isDark ? Colors.grey[850]! : Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HUIT CINEMA TICKET',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'SANDBOX MODE',
                  style: TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _movieTitle,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTicketRow(Icons.calendar_today_outlined, 'Lịch chiếu', _showtime, isDark),
          const Divider(height: 24, color: Colors.grey),
          _buildTicketRow(Icons.chair_outlined, 'Ghế đã chọn', _seats, isDark),
          const Divider(height: 24, color: Colors.grey),
          _buildTicketRow(Icons.confirmation_number_outlined, 'Mã đơn hàng', _orderId, isDark),
        ],
      ),
    );
  }

  Widget _buildTicketRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Custom Selectable Payment Tile
  Widget _buildPaymentTile({
    required PaymentMethod method,
    required String title,
    required String subtitle,
    required Widget logo,
    required bool isDark,
  }) {
    final bool isSelected = _selectedMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark 
              ? (isSelected ? const Color(0xFF241619) : const Color(0xFF1E1E1E))
              : (isSelected ? const Color(0xFFFDF2F4) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.redAccent : (isDark ? Colors.grey[850]! : Colors.grey[200]!),
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Selection indicator
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Colors.redAccent : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            // Logo container
            Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              child: logo,
            ),
            const SizedBox(width: 14),
            // Title and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fixed Bottom checkout bar
  Widget _buildBottomCheckoutBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Tổng thanh toán', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  '170.000 VNĐ',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                onPressed: _handleCheckout,
                child: const Text(
                  'Tiến hành thanh toán',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Brand Logos (Vector Draw using flutter Widgets) ---

  Widget _buildMoMoLogo() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFA50064),
        borderRadius: BorderRadius.circular(9),
      ),
      alignment: Alignment.center,
      child: const Text(
        'momo',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: -0.5),
      ),
    );
  }

  Widget _buildZaloPayLogo() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFF0088FF),
        borderRadius: BorderRadius.circular(9),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Zalo',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: -0.5),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFF00A25B),
              borderRadius: BorderRadius.circular(2),
            ),
            child: const Text(
              'Pay',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVNPayLogo() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFF005BAA),
        borderRadius: BorderRadius.circular(9),
      ),
      alignment: Alignment.center,
      child: const Text(
        'VN\nPAY',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white, 
          fontWeight: FontWeight.bold, 
          fontSize: 10, 
          height: 1.1,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
