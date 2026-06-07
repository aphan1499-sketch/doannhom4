import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/payment_service.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String url;
  final String orderId;

  const PaymentWebViewScreen({
    super.key,
    required this.url,
    required this.orderId,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  int _loadingProgress = 0;
  bool _isPageFinished = false;

  @override
  void initState() {
    super.initState();

    final String vnpayReturnUrl = dotenv.env['VNPAY_RETURN_URL'] ?? 
        'https://sandbox.vnpayment.vn/sdk_vnpay/vnpay_return.html';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF121212))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isPageFinished = false;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isPageFinished = true;
            });
          },
          onNavigationRequest: (NavigationRequest request) async {
            final String url = request.url;
            print("[PaymentWebView] Intercepting navigation to: $url");

            // Intercept VNPay return URL redirect
            if (url.startsWith(vnpayReturnUrl)) {
              print("[PaymentWebView] Captured return redirect url: $url");
              final Uri uri = Uri.parse(url);
              
              // VNPay success code is "00"
              final String? responseCode = uri.queryParameters['vnp_ResponseCode'];
              final bool isSuccess = responseCode == '00';

              print("[PaymentWebView] VNPay payment responseCode: $responseCode -> isSuccess: $isSuccess");

              // Sync the outcome to Firestore
              final PaymentService paymentService = PaymentService();
              await paymentService.updateBookingStatus(
                orderId: widget.orderId,
                isSuccess: isSuccess,
              );

              // Return result to previous screen
              Get.back(result: isSuccess);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        // Confirm before exiting payment gateway
        final bool? shouldExit = await Get.dialog<bool>(
          AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Xác nhận hủy',
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
            content: Text(
              'Bạn có chắc chắn muốn thoát khỏi cổng thanh toán? Đăng ký gói VIP của bạn sẽ không được hoàn tất.',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Quay lại thanh toán', style: TextStyle(color: Colors.redAccent)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  // Mark reservation as failed in Firestore before quitting
                  final PaymentService paymentService = PaymentService();
                  paymentService.updateBookingStatus(orderId: widget.orderId, isSuccess: false);
                  Get.back(result: true);
                },
                child: const Text('Thoát', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
        return shouldExit ?? false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1A1A),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () async {
              // Trigger WillPopScope logic
              final NavigatorState navigator = Navigator.of(context);
              if (await navigator.maybePop() == false) {
                Get.back(result: false);
              }
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cổng thanh toán VNPay',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Mã đơn hàng: ${widget.orderId}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          centerTitle: false,
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (!_isPageFinished || _loadingProgress < 100)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: _loadingProgress / 100.0,
                  backgroundColor: Colors.transparent,
                  color: Colors.redAccent,
                  minHeight: 3,
                ),
              ),
            if (!_isPageFinished)
              Container(
                color: const Color(0xFF121212).withOpacity(0.8),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.redAccent),
                      SizedBox(height: 16),
                      Text(
                        'Đang kết nối cổng thanh toán an toàn...',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
