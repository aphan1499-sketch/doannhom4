import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/payment_service.dart';
import '../services/transaction_cache_service.dart';
import 'payment_webview_screen.dart';

class PaymentCheckoutScreen extends StatefulWidget {
  final String orderId;
  final String packageName;
  final double price;
  final int durationDays;

  const PaymentCheckoutScreen({
    super.key,
    required this.orderId,
    required this.packageName,
    required this.price,
    required this.durationDays,
  });

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  final PaymentService _paymentService = PaymentService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<DocumentSnapshot>? _bookingSubscription;
  PaymentMethod _selectedMethod = PaymentMethod.vnpay;
  bool _isLoading = false;
  bool _isFinalized = false; // Prevents duplicate triggers or pop actions

  @override
  void initState() {
    super.initState();
    // 1. Sync & Reserve VIP Order State in Firestore
    _initiateVipReservation();

    // 2. Start real-time Firestore Listener
    _listenToBookingStatus();
  }

  @override
  void dispose() {
    _bookingSubscription?.cancel();
    super.dispose();
  }

  /// Sets state to pending in Firestore
  Future<void> _initiateVipReservation() async {
    final String activeUid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    await TransactionCacheService.saveTransaction(
      userId: activeUid,
      orderId: widget.orderId,
      packageName: widget.packageName,
      amount: widget.price,
      status: 'pending',
    );

    try {
      await _firestore.collection('bookings').doc(widget.orderId).set({
        'orderId': widget.orderId,
        'userId': activeUid,
        'movieTitle': widget.packageName, // Stored as plan name/description
        'amount': widget.price,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print("[PaymentCheckout] VIP Reservation initialized in Firestore.");
    } catch (e) {
      print("[PaymentCheckout] Firestore initial reservation error: $e");
    }
  }

  /// Real-time stream listener for Firestore document status changes
  void _listenToBookingStatus() {
    _bookingSubscription = _firestore
        .collection('bookings')
        .doc(widget.orderId)
        .snapshots()
        .listen(
          (DocumentSnapshot snapshot) {
            if (!snapshot.exists || _isFinalized) return;

            final data = snapshot.data() as Map<String, dynamic>?;
            if (data == null) return;

            final String status = data['status'] ?? 'pending';
            print("[PaymentCheckout] Real-time Status Update: $status");

            if (status == 'success') {
              _handleSuccess();
            } else if (status == 'cancelled') {
              _isFinalized = true;
              final userId = FirebaseAuth.instance.currentUser?.uid;
              if (userId != null) {
                TransactionCacheService.updateStatus(
                  userId: userId,
                  orderId: widget.orderId,
                  status: 'cancelled',
                );
              }
              _showOutcomeDialog(
                title: 'Giao dịch đã hủy',
                message: 'Đăng ký gói VIP đã bị hủy bỏ hoặc thất bại.',
                isSuccess: false,
              );
            }
          },
          onError: (e) {
            print("[PaymentCheckout] Real-time Firestore stream error: $e");
          },
        );
  }

  /// Handle successful payment and user database VIP upgrade
  Future<void> _handleSuccess() async {
    if (_isFinalized) return;
    _isFinalized = true;

    _bookingSubscription?.cancel();

    setState(() {
      _isLoading = true;
    });

    // Dual-write safety: Force upgrade current user document to VIP status
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final DateTime expiryDate = DateTime.now().add(
          Duration(days: widget.durationDays),
        );
        await TransactionCacheService.updateStatus(
          userId: currentUser.uid,
          orderId: widget.orderId,
          status: 'success',
        );
        await _firestore.collection('users').doc(currentUser.uid).set({
          'isVip': true,
          'subscriptionPlan': widget.packageName,
          'vipExpiryDate': expiryDate.toIso8601String(),
          'lastPaymentAmount': widget.price,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print(
          "[PaymentCheckout] User ${currentUser.uid} VIP updated to: ${widget.packageName}",
        );
      } catch (e) {
        print("[PaymentCheckout] Double write safety error: $e");
      }
    }

    setState(() {
      _isLoading = false;
    });

    _showOutcomeDialog(
      title: 'Đăng ký VIP thành công',
      message:
          'Chúc mừng! Tài khoản của bạn đã được nâng cấp lên ${widget.packageName}. Mở khóa toàn bộ đặc quyền xem phim Premium cực đỉnh!',
      isSuccess: true,
    );
  }

  /// Triggers actual payment gateways (MoMo, ZaloPay, VNPay Sandbox)
  Future<void> _handleCheckout() async {
    if (_isFinalized) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final String? paymentUrl = await _paymentService.processCheckout(
        amount: widget.price,
        orderId: widget.orderId,
        method: _selectedMethod,
        movieTitle: widget.packageName,
      );

      if (paymentUrl == "mock://payment-success") {
        setState(() {
          _isLoading = true;
        });
        await Future.delayed(const Duration(milliseconds: 1500));
        setState(() {
          _isLoading = false;
        });
        _handleSuccess();
        return;
      }

      setState(() {
        _isLoading = false;
      });

      if (paymentUrl == null && _selectedMethod != PaymentMethod.vnpay) {
        Get.snackbar(
          'Lỗi cổng Sandbox',
          'Không thể khởi tạo cổng thanh toán. Kiểm thử tệp tin cấu hình .env.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }

      if (_selectedMethod == PaymentMethod.vnpay) {
        // Launch native WebView for VNPay sandbox
        final bool? isSuccess = await Get.to<bool>(
          () => PaymentWebViewScreen(url: paymentUrl!, orderId: widget.orderId),
        );

        if (isSuccess == true) {
          _handleSuccess();
        } else {
          Get.snackbar(
            'Thanh toán thất bại',
            'Giao dịch qua cổng VNPay Sandbox không hoàn tất.',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      } else {
        // Deep link redirection launch for MoMo and ZaloPay Sandbox
        final bool launched = await _paymentService.launchPaymentLink(
          paymentUrl!,
        );
        if (launched) {
          _showSandboxConfirmDialog();
        } else {
          Get.snackbar(
            'Lỗi liên kết',
            'Không thể kích hoạt sâu liên kết ứng dụng ví điện tử.',
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar(
        'Lỗi hệ thống',
        'Có sự cố phát sinh khi kết nối: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  /// Simulator sandbox buttons for quick developer validation
  void _showSandboxConfirmDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.payments_outlined, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text(
              'Simulate Response',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        content: const Text(
          'Đây là cổng Sandbox thử nghiệm. Bạn có muốn mô phỏng phản hồi "Thành công" lên Firestore ngay không?',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Get.back();
              await _paymentService.updateBookingStatus(
                orderId: widget.orderId,
                isSuccess: false,
              );
            },
            child: const Text(
              'Thất bại',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Get.back();
              await _paymentService.updateBookingStatus(
                orderId: widget.orderId,
                isSuccess: true,
              );
            },
            child: const Text(
              'Thành công',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// General payment status outcome dialog
  void _showOutcomeDialog({
    required String title,
    required String message,
    required bool isSuccess,
  }) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Center(
          child: Column(
            children: [
              Icon(
                isSuccess ? Icons.stars_rounded : Icons.cancel_outlined,
                color: isSuccess ? Colors.amber : Colors.redAccent,
                size: 64,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSuccess ? Colors.amber : Colors.redAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Get.back(); // Dismiss outcome dialog
                if (isSuccess) {
                  // Clean navigation back to the Dashboard/Home Screen
                  Navigator.of(context).popUntil((route) => route.isFirst);
                } else {
                  Get.back(); // Simply pop checkout screen back to selection
                }
              },
              child: Text(
                'Đóng',
                style: TextStyle(
                  color: isSuccess ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121214),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Thanh Toán VIP',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Invoice style summary Card
                _buildInvoiceSummary(),
                const SizedBox(height: 32),

                const Text(
                  'Chọn phương thức thanh toán',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // MoMo Choice
                _buildPaymentChoiceTile(
                  method: PaymentMethod.momo,
                  title: 'Ví điện tử MoMo Sandbox',
                  subtitle: 'Mô phỏng thanh toán liên kết nhanh MoMo',
                  logo: _buildMoMoLogo(),
                ),
                const SizedBox(height: 12),

                // ZaloPay Choice
                _buildPaymentChoiceTile(
                  method: PaymentMethod.zalopay,
                  title: 'Ví điện tử ZaloPay Sandbox',
                  subtitle: 'Mô phỏng liên kết ví ZaloPay',
                  logo: _buildZaloPayLogo(),
                ),
                const SizedBox(height: 12),

                // VNPay Choice
                _buildPaymentChoiceTile(
                  method: PaymentMethod.vnpay,
                  title: 'Cổng thanh toán VNPay Sandbox',
                  subtitle: 'Thẻ ATM nội địa, Visa/MasterCard Sandbox',
                  logo: _buildVNPayLogo(),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),

          // Bottom sticky purchase activation bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomActivationBar(),
          ),

          // Screen Loading overlay spinner
          if (_isLoading)
            Container(
              color: Colors.black87.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.amber),
                    SizedBox(height: 16),
                    Text(
                      'Đang truyền mã hóa dữ liệu giao dịch...',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Gorgeous Premium Cinematic Invoice Style Details Card
  Widget _buildInvoiceSummary() {
    final String formattedPrice =
        '${widget.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF121214),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'THÔNG TIN HÓA ĐƠN',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 10),
                    SizedBox(width: 4),
                    Text(
                      'PREMIUM VIP',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Thanh Toán Gói VIP',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 24),

          _buildInvoiceRow(
            Icons.folder_special_outlined,
            'Gói dịch vụ',
            widget.packageName,
          ),
          const Divider(height: 32, color: Colors.white10),
          _buildInvoiceRow(
            Icons.timer_outlined,
            'Thời hạn sử dụng',
            '${widget.durationDays} Ngày',
          ),
          const Divider(height: 32, color: Colors.white10),
          _buildInvoiceRow(
            Icons.receipt_long_outlined,
            'Mã giao dịch',
            widget.orderId,
          ),
          const Divider(height: 32, color: Colors.white10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng thanh toán:',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              Text(
                formattedPrice,
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Payment selection list tile
  Widget _buildPaymentChoiceTile({
    required PaymentMethod method,
    required String title,
    required String subtitle,
    required Widget logo,
  }) {
    final bool isSelected = _selectedMethod == method;

    return GestureDetector(
      onTap: () {
        if (_isFinalized) return;
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E1C1A) : const Color(0xFF121214),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.white.withOpacity(0.04),
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Colors.amber : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 12),
            SizedBox(width: 44, height: 44, child: logo),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActivationBar() {
    final String formattedPrice =
        '${widget.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F10),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Tổng thanh toán',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formattedPrice,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isFinalized ? null : _handleCheckout,
              child: const Text(
                'KÍCH HOẠT VIP',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Brand Logos ---

  Widget _buildMoMoLogo() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFA50064),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Text(
        'momo',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildZaloPayLogo() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0088FF),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Zalo',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 9,
              letterSpacing: -0.5,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFF00A25B),
              borderRadius: BorderRadius.circular(2),
            ),
            child: const Text(
              'Pay',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVNPayLogo() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF005BAA),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Text(
        'VN\nPAY',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 9,
          height: 1.1,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
