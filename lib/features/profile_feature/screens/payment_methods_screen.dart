import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'add_credit_card_screen.dart';
import 'link_bank_screen.dart';

class PaymentMethodsScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  PaymentMethodsScreen({super.key});

  // Hiển thị BottomSheet lựa chọn hình thức QR
  void _showQRMethodsBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thanh indicator trên cùng của BottomSheet
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            
            Text(
              'Thanh toán bằng QR Code',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Chọn phương thức quét camera hoặc nhận mã VietQR',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),

            // Tùy chọn 1: Quét mã QR bằng Camera
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.redAccent),
              ),
              title: const Text('Quét mã QR từ Camera', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Mở camera quét nhanh mã QR tại quầy vé'),
              onTap: () {
                Get.back();
                Get.to(() => const SimulatedQRScanner());
              },
            ),
            const Divider(height: 16),

            // Tùy chọn 2: Hiển thị mã VietQR nhận tiền
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.qr_code_rounded, color: Colors.blueAccent),
              ),
              title: const Text('Mã VietQR của tôi', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Hiển thị VietQR nhận tiền chuyển khoản nhanh 2s'),
              onTap: () {
                Get.back();
                _showVietQRDialog(context);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // Hiển thị BottomSheet Thêm phương thức thanh toán mới
  void _showAddPaymentMethodBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            
            Text(
              'Thêm phương thức mới',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Vui lòng chọn loại tài khoản hoặc ví bạn muốn liên kết',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),

            // Tùy chọn 1: Thẻ Visa quốc tế
            ListTile(
              leading: SizedBox(
                width: 88,
                height: 34,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VisaLogoWidget(height: 10, textColor: Color(0xFF1A1F71)),
                        SizedBox(width: 4),
                        Text('|', style: TextStyle(color: Colors.grey, fontSize: 8)),
                        SizedBox(width: 4),
                        MastercardLogoWidget(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
              title: const Text('Thẻ quốc tế Visa / Mastercard', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Thanh toán quốc tế bảo mật tuyệt đối'),
              onTap: () {
                Get.back();
                Get.to(() => AddCreditCardScreen());
              },
            ),
            const Divider(height: 16),

            // Tùy chọn 2: Ngân hàng nội địa Napas
            ListTile(
              leading: SizedBox(
                width: 88,
                height: 34,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_rounded, color: Colors.green, size: 20),
                  ),
                ),
              ),
              title: const Text('Liên kết Ngân hàng nội địa', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Chọn và liên kết tài khoản thẻ Napas nhanh chóng'),
              onTap: () {
                Get.back();
                Get.to(() => const LinkBankScreen());
              },
            ),
            const Divider(height: 16),

            // Tùy chọn 3: Ví điện tử (MoMo / ZaloPay)
            ListTile(
              leading: SizedBox(
                width: 88,
                height: 34,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MoMoLogoWidget(size: 18),
                        SizedBox(width: 4),
                        Text('|', style: TextStyle(color: Colors.grey, fontSize: 8)),
                        SizedBox(width: 4),
                        ZaloPayLogoWidget(height: 15),
                      ],
                    ),
                  ),
                ),
              ),
              title: const Text('Ví điện tử (MoMo / ZaloPay)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Liên kết nhanh ví điện tử tiện lợi'),
              onTap: () {
                Get.back();
                _showWalletSelectionBottomSheet(context);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // Hiển thị BottomSheet lựa chọn ví điện tử (MoMo / ZaloPay)
  void _showWalletSelectionBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            
            Text(
              'Chọn Ví Điện Tử',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Hỗ trợ liên kết siêu tốc bằng QR hoặc Số điện thoại',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),

            // MoMo
            ListTile(
              leading: const SizedBox(
                width: 88,
                height: 34,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: MoMoLogoWidget(size: 34),
                ),
              ),
              title: const Text('Ví điện tử MoMo', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Liên kết ví MoMo chuẩn an toàn'),
              onTap: () {
                Get.back();
                _showLinkWalletDialog(context, 'momo');
              },
            ),
            const Divider(height: 16),

            // ZaloPay
            ListTile(
              leading: const SizedBox(
                width: 88,
                height: 34,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ZaloPayLogoWidget(height: 26),
                ),
              ),
              title: const Text('Ví điện tử ZaloPay', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Liên kết ví ZaloPay nhanh gọn'),
              onTap: () {
                Get.back();
                _showLinkWalletDialog(context, 'zalopay');
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, String id, String typeName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: isDark ? Border.all(color: Colors.white.withOpacity(0.05)) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_forever_rounded, 
                  color: Colors.redAccent, 
                  size: 32
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Xóa phương thức thanh toán',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Bạn có chắc chắn muốn hủy liên kết phương thức này ($typeName) không?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: isDark ? Colors.white.withOpacity(0.12) : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: Text(
                        'Hủy',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        authController.deletePaymentMethod(id);
                        Get.back();
                        Get.snackbar(
                          'Thành công', 
                          'Đã hủy liên kết phương thức thanh toán!',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      },
                      child: const Text(
                        'Xóa',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  void _showLinkWalletDialog(BuildContext context, String walletType) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final phoneController = TextEditingController(text: authController.userPhone.value != 'Chưa cập nhật' ? authController.userPhone.value : '');
    final formKey = GlobalKey<FormState>();
    final themeColor = walletType == 'momo' ? const Color(0xFFD82780) : const Color(0xFF0068FF);
    final walletName = walletType == 'momo' ? 'MoMo' : 'ZaloPay';

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: isDark ? Border.all(color: Colors.white.withOpacity(0.05)) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        walletType == 'momo' ? Icons.account_balance_wallet_outlined : Icons.account_balance_wallet_rounded,
                        color: themeColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Liên kết Ví $walletName',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: isDark ? Colors.grey : Colors.black54),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Chọn quét mã QR của ví trên app khác hoặc tải ảnh mã QR ví từ thư viện để liên kết nhanh trong 2 giây!',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Get.back();
                          Get.to(() => SimulatedWalletQRScanner(walletType: walletType));
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: themeColor.withOpacity(0.3), width: 1.5),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.qr_code_scanner_rounded, color: themeColor, size: 28),
                              const SizedBox(height: 8),
                              Text(
                                'Quét mã QR Ví',
                                style: TextStyle(color: themeColor, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Get.back();
                          Get.to(() => SimulatedGalleryPicker(walletType: walletType));
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark ? Colors.white.withOpacity(0.12) : Colors.grey.withOpacity(0.2),
                              width: 1.5
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.photo_library_rounded, color: isDark ? Colors.white70 : Colors.black87, size: 28),
                              const SizedBox(height: 8),
                              Text(
                                'Tải lên ảnh QR',
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.black87, 
                                  fontSize: 13, 
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Divider(color: isDark ? Colors.white10 : Colors.grey[200])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'HOẶC NHẬP THỦ CÔNG',
                        style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                      ),
                    ),
                    Expanded(child: Divider(color: isDark ? Colors.white10 : Colors.grey[200])),
                  ],
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.phone_iphone_rounded, color: themeColor),
                    labelText: 'Số điện thoại ví',
                    labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: themeColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    if (value.trim().length < 9 || value.trim().length > 11) {
                      return 'Số điện thoại không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final phone = phoneController.text.trim();
                            final maskedPhone = phone.length >= 7 
                                ? '${phone.substring(0, 3)}****${phone.substring(phone.length - 3)}'
                                : phone;
                            
                            authController.addPaymentMethod({
                              'id': DateTime.now().millisecondsSinceEpoch.toString(),
                              'type': walletType,
                              'phone': maskedPhone,
                              'isDefault': false,
                              'gradientColors': walletType == 'momo'
                                  ? [0xFFD82780, 0xFFE11B74]
                                  : [0xFF0068FF, 0xFF00C6FF],
                            });
                            
                            Get.back();
                            Get.snackbar(
                              'Liên kết thành công', 
                              'Ví $walletName đã được liên kết!',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          }
                        },
                        child: const Text(
                          'Xác nhận liên kết',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  void _showVietQRDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: isDark ? Border.all(color: Colors.white.withOpacity(0.05)) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Thanh toán nhanh VietQR',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: isDark ? Colors.white60 : Colors.black54),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(Icons.qr_code_2_rounded, size: 200, color: const Color(0xFF002B66)),
                          ),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF002B66),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'VietQR',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0073BC),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'napas',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ngân hàng', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        Text('Vietcombank (VCB)', style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Số tài khoản', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        Text('1022 4589 6632', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tên tài khoản', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        Text('CONG TY CO PHAN CINEMAX', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              Text(
                'Mở ứng dụng ngân hàng quét mã để thanh toán tức thì mà không cần nhập tay!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600], height: 1.4),
              ),
            ],
          ),
        ),
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
          'Phương thức thanh toán',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Quét mã QR thanh toán',
            onPressed: () => _showQRMethodsBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. BANNER THÔNG BÁO RÚT GỌN (UI/UX Component 1)
          const PaymentBanner(),

          // 2. DANH SÁCH THẺ THANH TOÁN (UI/UX Component 2)
          Expanded(
            child: Obx(() {
              if (authController.paymentMethods.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.credit_card_off_rounded, size: 80, color: isDark ? Colors.grey[800] : Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có phương thức thanh toán nào',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                itemCount: authController.paymentMethods.length,
                itemBuilder: (context, index) {
                  final method = authController.paymentMethods[index];
                  
                  return PaymentCardWidget(
                    method: method,
                    onOptionSelected: (action) {
                      final String id = method['id'];
                      final String type = method['type'];
                      
                      if (action == 'default') {
                        authController.setDefaultPaymentMethod(id);
                        Get.snackbar(
                          'Thành công', 
                          'Đã thiết lập phương thức mặc định!',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      } else if (action == 'delete') {
                        _showDeleteConfirmDialog(
                          context, 
                          id, 
                          type == 'visa' 
                              ? 'Thẻ Visa' 
                              : (type == 'momo' 
                                  ? 'Ví MoMo' 
                                  : (type == 'zalopay' ? 'Ví ZaloPay' : 'Tài khoản Ngân hàng'))
                        );
                      }
                    },
                  );
                },
              );
            }),
          ),

          // 3. KHU VỰC THAO TÁC Bottom Control (Tái cấu trúc lại lộn xộn)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // KHỐI CHỨC NĂNG QR SIÊU CẤP ĐỘC QUYỀN (UI/UX Component 3)
                  QRActionBlock(
                    onPressed: () => _showQRMethodsBottomSheet(context),
                  ),
                  const SizedBox(height: 18),

                  // NÚT THÊM PHƯƠNG THỨC MỚI TINH TẾ (UI/UX Component 4)
                  AddPaymentMethodButton(
                    onPressed: () => _showAddPaymentMethodBottomSheet(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// COMPONENT 1: BANNER THÔNG BÁO RÚT GỌN TINH TẾ
// =====================================================================

class PaymentBanner extends StatelessWidget {
  const PaymentBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent.withOpacity(0.18)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield_outlined, color: Colors.redAccent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Hệ thống liên kết an toàn. Quét mã QR để thanh toán nhanh chóng!',
                style: TextStyle(
                  color: isDark ? Colors.grey[300] : Colors.grey[700], 
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// COMPONENT 2: THIẾT KẾ THẺ CAO CẤP CHUẨN QUỐC TẾ & NỘI ĐỊA
// =====================================================================

class PaymentCardWidget extends StatelessWidget {
  final Map<String, dynamic> method;
  final Function(String) onOptionSelected;

  const PaymentCardWidget({
    super.key,
    required this.method,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final String type = method['type'];
    final bool isDefault = method['isDefault'] ?? false;
    final List<int> gradientInts = List<int>.from(method['gradientColors']);
    final List<Color> gradientColors = gradientInts.map((c) => Color(c)).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 165,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Hàng 1: Logo & Option badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cấu trúc logo thẻ/ví
                  _buildLogoWidget(type),
                  
                  // Default Badge & Menu Button
                  Row(
                    children: [
                      if (type == 'visa')
                        const Padding(
                          padding: EdgeInsets.only(right: 12.0),
                          child: Icon(Icons.wifi_rounded, color: Colors.white70, size: 20),
                        ),
                      
                      if (isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'Mặc định',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onSelected: onOptionSelected,
                        itemBuilder: (context) => [
                          if (!isDefault)
                            const PopupMenuItem(
                              value: 'default',
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                                  SizedBox(width: 10),
                                  Text('Đặt làm mặc định'),
                                ],
                              ),
                            ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                SizedBox(width: 10),
                                Text('Hủy liên kết'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              // Hàng 2: Số thẻ dập nổi / Số điện thoại / Số tài khoản
              _buildNumberWidget(type),

              // Hàng 3: Tên chủ tài khoản & Chip vàng kim
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type == 'visa' 
                            ? 'CHỦ THẺ' 
                            : (type == 'bank' ? 'CHỦ TÀI KHOẢN' : 'VÍ ĐIỆN TỬ'),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        type == 'visa' 
                            ? (method['cardHolder'] ?? '').toUpperCase()
                            : (type == 'bank'
                                ? (method['accountHolder'] ?? '').toUpperCase()
                                : 'ĐÃ XÁC THỰC'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  
                  // Chip 3D cho các phương thức ngân hàng
                  if (type == 'visa' || type == 'bank')
                    Container(
                      width: 32,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF2C94C), Color(0xFFF2994A)],
                        ),
                        borderRadius: BorderRadius.circular(4),
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

  Widget _buildLogoWidget(String type) {
    if (type == 'visa') {
      final cardBrand = method['cardBrand'] ?? 'visa';
      if (cardBrand == 'mastercard') {
        return const MastercardLogoWidget(height: 22);
      }
      final cardNo = method['cardNo'] ?? '';
      if (cardNo.startsWith('5') || cardNo.startsWith('2')) {
        return const MastercardLogoWidget(height: 22);
      }
      return const VisaLogoWidget(height: 22);
    } else if (type == 'momo') {
      return Row(
        children: [
          const MoMoLogoWidget(size: 34),
          const SizedBox(width: 10),
          const Text(
            'MoMo Wallet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else if (type == 'zalopay') {
      return Row(
        children: [
          const ZaloPayLogoWidget(height: 26),
          const SizedBox(width: 10),
          const Text(
            'ZaloPay Wallet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              color: Color(0xFF007A33),
              size: 14,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            method['bankName'] ?? 'Ngân hàng',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildNumberWidget(String type) {
    if (type == 'visa') {
      return Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: Text(
          method['cardNo'] ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.5,
            fontFamily: 'monospace',
          ),
        ),
      );
    } else if (type == 'bank') {
      return Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: Text(
          method['accountNo'] ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
            fontFamily: 'monospace',
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: Text(
          'SĐT: ${method['phone']}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
          ),
        ),
      );
    }
  }
}

// =====================================================================
// COMPONENT 3: KHỐI CHỨC NĂNG QR SIÊU CẤP ĐỘC QUYỀN (NEON GLOW QR CARD)
// =====================================================================

class QRActionBlock extends StatelessWidget {
  final VoidCallback onPressed;

  const QRActionBlock({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: isDark 
              ? [const Color(0xFF2C0F11), const Color(0xFF1E1E24)]
              : [const Color(0xFFFFF0F1), const Color(0xFFF9F9FB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.redAccent.withOpacity(isDark ? 0.35 : 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(isDark ? 0.08 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Row(
              children: [
                // Biểu tượng quét QR lớn được bao quanh bởi khung phát sáng
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded, 
                    color: Colors.redAccent, 
                    size: 32
                  ),
                ),
                const SizedBox(width: 16),
                
                // Tiêu đề & Mô tả hành động
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QUÉT QR / MÃ VIETQR',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quét Camera nhanh tại quầy hoặc nhận VietQR chuyển khoản cực tốc',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Mũi tên chỉ hướng trượt
                Icon(
                  Icons.arrow_forward_ios_rounded, 
                  color: isDark ? Colors.grey[600] : Colors.grey[400], 
                  size: 14
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// COMPONENT 4: NÚT THÊM PHƯƠNG THỨC MỚI TINH TẾ (DASHED-OUTLINED EFFECT)
// =====================================================================

class AddPaymentMethodButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddPaymentMethodButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        icon: Icon(
          Icons.add_circle_outline_rounded, 
          color: isDark ? Colors.white70 : Colors.black87,
          size: 18,
        ),
        label: Text(
          'Thêm phương thức thanh toán mới',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.12) : Colors.grey.withOpacity(0.3),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

// =====================================================================
// STANDALONE HIGH-FIDELITY SIMULATED QR CAMERA SCANNER WITH SLIDING LASER
// =====================================================================

class SimulatedQRScanner extends StatefulWidget {
  const SimulatedQRScanner({super.key});

  @override
  State<SimulatedQRScanner> createState() => _SimulatedQRScannerState();
}

class _SimulatedQRScannerState extends State<SimulatedQRScanner> with SingleTickerProviderStateMixin {
  late AnimationController _laserController;
  late Animation<double> _laserAnimation;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        Get.back();
        Get.snackbar(
          'Thanh toán thành công',
          'Đã quét mã QR và xác thực thanh toán vé xem phim thành công!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      }
    });
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF140203), Color(0xFF070001)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          Opacity(
            opacity: 0.15,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://www.transparenttextures.com/patterns/asfalt-dark.png'),
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
          ),

          LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              final double height = constraints.maxHeight;
              final double scanSize = width * 0.65;
              final double left = (width - scanSize) / 2;
              final double top = (height - scanSize) / 2 - 40;

              return Stack(
                children: [
                  Positioned(
                    left: left,
                    top: top,
                    width: scanSize,
                    height: scanSize,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0, top: 0,
                            child: Container(
                              width: 30, height: 30,
                              decoration: const BoxDecoration(
                                border: Border(
                                  left: BorderSide(color: Colors.redAccent, width: 4),
                                  top: BorderSide(color: Colors.redAccent, width: 4),
                                ),
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0, top: 0,
                            child: Container(
                              width: 30, height: 30,
                              decoration: const BoxDecoration(
                                border: Border(
                                  right: BorderSide(color: Colors.redAccent, width: 4),
                                  top: BorderSide(color: Colors.redAccent, width: 4),
                                ),
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0, bottom: 0,
                            child: Container(
                              width: 30, height: 30,
                              decoration: const BoxDecoration(
                                border: Border(
                                  left: BorderSide(color: Colors.redAccent, width: 4),
                                  bottom: BorderSide(color: Colors.redAccent, width: 4),
                                ),
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20)),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0, bottom: 0,
                            child: Container(
                              width: 30, height: 30,
                              decoration: const BoxDecoration(
                                border: Border(
                                  right: BorderSide(color: Colors.redAccent, width: 4),
                                  bottom: BorderSide(color: Colors.redAccent, width: 4),
                                ),
                                borderRadius: BorderRadius.only(bottomRight: Radius.circular(20)),
                              ),
                            ),
                          ),

                          AnimatedBuilder(
                            animation: _laserAnimation,
                            builder: (context, child) {
                              final double laserTop = _laserAnimation.value * (scanSize - 8);
                              return Positioned(
                                top: laserTop,
                                left: 6,
                                right: 6,
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.greenAccent,
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.greenAccent.withOpacity(0.8),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          Center(
                            child: Icon(
                              Icons.qr_code_scanner_rounded, 
                              size: 70, 
                              color: Colors.white.withOpacity(0.08)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(top: 0, left: 0, right: 0, height: top, child: Container(color: Colors.black.withOpacity(0.65))),
                  Positioned(top: top + scanSize, left: 0, right: 0, bottom: 0, child: Container(color: Colors.black.withOpacity(0.65))),
                  Positioned(top: top, left: 0, width: left, height: scanSize, child: Container(color: Colors.black.withOpacity(0.65))),
                  Positioned(top: top, right: 0, width: left, height: scanSize, child: Container(color: Colors.black.withOpacity(0.65))),
                ],
              );
            },
          ),

          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                      const Text(
                        'Quét mã QR',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.flash_on_rounded, color: Colors.amber),
                        onPressed: () {
                          Get.snackbar(
                            'Flash', 
                            'Đã bật đèn Flash trợ sáng!',
                            backgroundColor: Colors.black.withOpacity(0.8),
                            colorText: Colors.white,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 64.0, left: 24.0, right: 24.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.redAccent, strokeWidth: 2),
                        SizedBox(height: 14),
                        Text(
                          'Đang căn chỉnh camera...',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Đưa khung ngắm vào mã QR trên vé hoặc thiết bị khác để quét tự động.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// STANDALONE HIGH-FIDELITY SIMULATED QR CAMERA SCANNER WITH SLIDING LASER FOR WALLETS
// =====================================================================

class SimulatedWalletQRScanner extends StatefulWidget {
  final String walletType;

  const SimulatedWalletQRScanner({super.key, required this.walletType});

  @override
  State<SimulatedWalletQRScanner> createState() => _SimulatedWalletQRScannerState();
}

class _SimulatedWalletQRScannerState extends State<SimulatedWalletQRScanner> with SingleTickerProviderStateMixin {
  late AnimationController _laserController;
  late Animation<double> _laserAnimation;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        final AuthController authController = Get.find<AuthController>();
        final walletName = widget.walletType == 'momo' ? 'MoMo' : 'ZaloPay';
        
        final randomPhone = '09${Random().nextInt(90000000) + 10000000}';
        final maskedPhone = '${randomPhone.substring(0, 3)}****${randomPhone.substring(7)}';

        authController.addPaymentMethod({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'type': widget.walletType,
          'phone': maskedPhone,
          'isDefault': false,
          'gradientColors': widget.walletType == 'momo'
              ? [0xFFD82780, 0xFFE11B74]
              : [0xFF0068FF, 0xFF00C6FF],
        });

        Get.back();
        Get.snackbar(
          'Liên kết thành công',
          'Đã quét mã QR và liên kết Ví $walletName ($maskedPhone) thành công!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      }
    });
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.walletType == 'momo' ? const Color(0xFFD82780) : const Color(0xFF0068FF);
    final walletName = widget.walletType == 'momo' ? 'MoMo' : 'ZaloPay';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F0F10), Color(0xFF020202)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          Opacity(
            opacity: 0.12,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://www.transparenttextures.com/patterns/asfalt-dark.png'),
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
          ),

          LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              final double height = constraints.maxHeight;
              final double scanSize = width * 0.65;
              final double left = (width - scanSize) / 2;
              final double top = (height - scanSize) / 2 - 40;

              return Stack(
                children: [
                  Positioned(
                    left: left,
                    top: top,
                    width: scanSize,
                    height: scanSize,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0, top: 0,
                            child: Container(
                              width: 30, height: 30,
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(color: themeColor, width: 4),
                                  top: BorderSide(color: themeColor, width: 4),
                                ),
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20)),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0, top: 0,
                            child: Container(
                              width: 30, height: 30,
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(color: themeColor, width: 4),
                                  top: BorderSide(color: themeColor, width: 4),
                                ),
                                borderRadius: const BorderRadius.only(topRight: Radius.circular(20)),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0, bottom: 0,
                            child: Container(
                              width: 30, height: 30,
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(color: themeColor, width: 4),
                                  bottom: BorderSide(color: themeColor, width: 4),
                                ),
                                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20)),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0, bottom: 0,
                            child: Container(
                              width: 30, height: 30,
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(color: themeColor, width: 4),
                                  bottom: BorderSide(color: themeColor, width: 4),
                                ),
                                borderRadius: const BorderRadius.only(bottomRight: Radius.circular(20)),
                              ),
                            ),
                          ),

                          AnimatedBuilder(
                            animation: _laserAnimation,
                            builder: (context, child) {
                              final double laserTop = _laserAnimation.value * (scanSize - 8);
                              return Positioned(
                                top: laserTop,
                                left: 6,
                                right: 6,
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: themeColor,
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: themeColor.withOpacity(0.8),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          Center(
                            child: Icon(
                              Icons.qr_code_2_rounded, 
                              size: 100, 
                              color: Colors.white.withOpacity(0.06)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(top: 0, left: 0, right: 0, height: top, child: Container(color: Colors.black.withOpacity(0.7))),
                  Positioned(top: top + scanSize, left: 0, right: 0, bottom: 0, child: Container(color: Colors.black.withOpacity(0.7))),
                  Positioned(top: top, left: 0, width: left, height: scanSize, child: Container(color: Colors.black.withOpacity(0.7))),
                  Positioned(top: top, right: 0, width: left, height: scanSize, child: Container(color: Colors.black.withOpacity(0.7))),
                ],
              );
            },
          ),

          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                      Text(
                        'Quét QR liên kết $walletName',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 64.0, left: 24.0, right: 24.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: themeColor, strokeWidth: 2),
                        const SizedBox(height: 14),
                        Text(
                          'Đang quét mã QR Ví $walletName...',
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Đang tự động nhận diện mã QR trên thiết bị khác.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// COMPONENT 5: THƯ VIỆN ẢNH GIẢ LẬP ĐỂ LIÊN KẾT VÍ QUA QR CODE SCREENSHOT
// =====================================================================

class SimulatedGalleryPicker extends StatefulWidget {
  final String walletType;

  const SimulatedGalleryPicker({super.key, required this.walletType});

  @override
  State<SimulatedGalleryPicker> createState() => _SimulatedGalleryPickerState();
}

class _SimulatedGalleryPickerState extends State<SimulatedGalleryPicker> {
  bool _isAnalyzing = false;
  String? _selectedImageName;

  void _analyzeQRImage(String imageName) {
    setState(() {
      _isAnalyzing = true;
      _selectedImageName = imageName;
    });

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        final AuthController authController = Get.find<AuthController>();
        final walletName = widget.walletType == 'momo' ? 'MoMo' : 'ZaloPay';
        
        final randomPhone = '09${Random().nextInt(90000000) + 10000000}';
        final maskedPhone = '${randomPhone.substring(0, 3)}****${randomPhone.substring(7)}';

        authController.addPaymentMethod({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'type': widget.walletType,
          'phone': maskedPhone,
          'isDefault': false,
          'gradientColors': widget.walletType == 'momo'
              ? [0xFFD82780, 0xFFE11B74]
              : [0xFF0068FF, 0xFF00C6FF],
        });

        Get.back();
        Get.snackbar(
          'Phân tích thành công',
          'Đã nhận dạng mã QR từ ảnh $_selectedImageName và liên kết Ví $walletName ($maskedPhone) thành công!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor = widget.walletType == 'momo' ? const Color(0xFFD82780) : const Color(0xFF0068FF);
    final walletName = widget.walletType == 'momo' ? 'MoMo' : 'ZaloPay';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text(
          'Chọn ảnh từ Thư viện',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ẢNH CHỤP GẦN ĐÂY (CHỌN ẢNH CHỤP QR VÍ)',
                  style: TextStyle(
                    fontSize: 11, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.grey[500],
                    letterSpacing: 1.0
                  ),
                ),
                const SizedBox(height: 16),
                
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    children: [
                      _buildGalleryItem(
                        context,
                        title: 'QR_MoMo_Wallet.png',
                        icon: Icons.qr_code_2_rounded,
                        accentColor: const Color(0xFFD82780),
                        isQR: true,
                        walletName: 'MoMo',
                      ),
                      _buildGalleryItem(
                        context,
                        title: 'ZaloPay_PayCode.png',
                        icon: Icons.qr_code_rounded,
                        accentColor: const Color(0xFF0068FF),
                        isQR: true,
                        walletName: 'ZaloPay',
                      ),
                      _buildGalleryItem(
                        context,
                        title: 'IMG_2489_Landscape.jpg',
                        icon: Icons.landscape_rounded,
                        accentColor: Colors.teal,
                        isQR: false,
                      ),
                      _buildGalleryItem(
                        context,
                        title: 'Cinemax_Ticket.jpg',
                        icon: Icons.local_activity_rounded,
                        accentColor: Colors.redAccent,
                        isQR: false,
                      ),
                      _buildGalleryItem(
                        context,
                        title: 'MoMo_QR_ScanMe.png',
                        icon: Icons.qr_code_2_rounded,
                        accentColor: const Color(0xFFD82780),
                        isQR: true,
                        walletName: 'MoMo',
                      ),
                      _buildGalleryItem(
                        context,
                        title: 'Family_Portrait.jpg',
                        icon: Icons.people_rounded,
                        accentColor: Colors.orange,
                        isQR: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_isAnalyzing)
            Container(
              color: Colors.black.withOpacity(0.85),
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: CircularProgressIndicator(
                            color: themeColor,
                            strokeWidth: 3,
                          ),
                        ),
                        Icon(Icons.qr_code_scanner_rounded, size: 44, color: themeColor),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Đang quét ảnh QR $_selectedImageName...',
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hệ thống AI đang giải mã dữ liệu Ví $walletName...',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGalleryItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color accentColor,
    required bool isQR,
    String? walletName,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        if (isQR) {
          _analyzeQRImage(title);
        } else {
          Get.snackbar(
            'Ảnh không hợp lệ',
            'Tấm ảnh này không chứa thông tin mã QR liên kết ví hợp lệ. Vui lòng chọn ảnh QR $walletName.',
            backgroundColor: Colors.amber[700],
            colorText: Colors.white,
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor.withOpacity(0.12), accentColor.withOpacity(0.25)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Icon(icon, color: accentColor, size: 36),
                  ),
                ),
              ),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                color: isDark ? Colors.black26 : Colors.grey[100],
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9, 
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.black87
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// VECTOR BRAND LOGOS DRAWN WITH HIGH-FIDELITY FLUTTER CANVAS & BOXES
// =====================================================================

class VisaLogoWidget extends StatelessWidget {
  final double height;
  final Color textColor;

  const VisaLogoWidget({super.key, this.height = 20, this.textColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // The elegant gold slice representing the wingtip of Visa from the provided image
          Transform.translate(
            offset: const Offset(1, -2),
            child: Transform.rotate(
              angle: -0.25,
              child: Container(
                width: 6,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFFF7B614),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(1.5),
                    bottomRight: Radius.circular(1.5),
                  ),
                ),
              ),
            ),
          ),
          Text(
            'VISA',
            style: TextStyle(
              color: textColor,
              fontSize: height * 0.95,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class MastercardLogoWidget extends StatelessWidget {
  final double height;

  const MastercardLogoWidget({super.key, this.height = 24});

  @override
  Widget build(BuildContext context) {
    final double width = height * 1.6;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // Left circle (Red)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: height,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFEB001B),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Right circle (Orange)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: height,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF79E1B).withOpacity(0.9),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Center blend slice to simulate intersection
          Positioned(
            left: width * 0.35,
            top: 0,
            bottom: 0,
            width: width * 0.3,
            child: Center(
              child: Container(
                width: height * 0.35,
                height: height * 0.75,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5F00),
                  borderRadius: BorderRadius.all(Radius.elliptical(height * 0.18, height * 0.38)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MoMoLogoWidget extends StatelessWidget {
  final double size;

  const MoMoLogoWidget({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFA50064), // Official MoMo deep pink from user image
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA50064).withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'momo',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.32,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              'MOBILE MONEY',
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: size * 0.09,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.05,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ZaloPayLogoWidget extends StatelessWidget {
  final double height;

  const ZaloPayLogoWidget({super.key, this.height = 28});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: height * 0.35, vertical: height * 0.1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(height * 0.25),
        border: Border.all(color: Colors.grey.withOpacity(0.18), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Zalo',
            style: TextStyle(
              color: const Color(0xFF0068FF), // Official Zalo Blue
              fontSize: height * 0.42,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              height: 1.0,
            ),
          ),
          SizedBox(width: height * 0.15),
          Container(
            padding: EdgeInsets.symmetric(horizontal: height * 0.18, vertical: height * 0.08),
            decoration: BoxDecoration(
              color: const Color(0xFF26B14C), // ZaloPay Green
              borderRadius: BorderRadius.circular(height * 0.12),
            ),
            child: Text(
              'Pay',
              style: TextStyle(
                color: Colors.white,
                fontSize: height * 0.28,
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
