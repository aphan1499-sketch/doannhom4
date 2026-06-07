import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'payment_methods_screen.dart';

class AddCreditCardScreen extends StatefulWidget {
  const AddCreditCardScreen({super.key});

  @override
  State<AddCreditCardScreen> createState() => _AddCreditCardScreenState();
}

class _AddCreditCardScreenState extends State<AddCreditCardScreen> {
  final AuthController authController = Get.find<AuthController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  String _cardNumber = '•••• •••• •••• ••••';
  String _cardHolder = 'TÊN CHỦ THẺ';
  String _expiry = 'MM/YY';

  @override
  void initState() {
    super.initState();

    // Listeners to update the live preview credit card
    _cardNumberController.addListener(() {
      setState(() {
        _cardNumber = _cardNumberController.text.isEmpty
            ? '•••• •••• •••• ••••'
            : _cardNumberController.text;
      });
    });

    _cardHolderController.addListener(() {
      setState(() {
        _cardHolder = _cardHolderController.text.isEmpty
            ? 'TÊN CHỦ THẺ'
            : _cardHolderController.text.toUpperCase();
      });
    });

    _expiryController.addListener(() {
      setState(() {
        _expiry = _expiryController.text.isEmpty
            ? 'MM/YY'
            : _expiryController.text;
      });
    });
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
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
          'Thêm thẻ tín dụng',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // 1. LIVE CREDIT CARD PREVIEW
              Builder(
                builder: (context) {
                  final bool isMaster =
                      _cardNumber.startsWith('5') ||
                      _cardNumber.startsWith('2');
                  return Container(
                    width: double.infinity,
                    height: 190,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: isMaster
                            ? [const Color(0xFFC33764), const Color(0xFF1D2671)]
                            : [
                                const Color(0xFF0F2027),
                                const Color(0xFF203A43),
                                const Color(0xFF2C5364),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (isMaster
                                      ? const Color(0xFFC33764)
                                      : const Color(0xFF0F2027))
                                  .withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Dòng 1: Chip thẻ & Brand VISA
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Chip thẻ
                              Container(
                                width: 40,
                                height: 30,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFF2C94C),
                                      Color(0xFFF2994A),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Container(
                                        width: 24,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.black.withValues(
                                              alpha: 0.15,
                                            ),
                                            width: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Container(
                                        width: 12,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.black.withValues(
                                              alpha: 0.15,
                                            ),
                                            width: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Brand
                              isMaster
                                  ? const MastercardLogoWidget(height: 22)
                                  : const VisaLogoWidget(height: 22),
                            ],
                          ),

                          // Dòng 2: Số thẻ
                          Text(
                            _cardNumber,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.5,
                              fontFamily: 'monospace',
                            ),
                          ),

                          // Dòng 3: Tên chủ thẻ & Ngày hết hạn
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'CHỦ THẺ',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.5,
                                        ),
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _cardHolder,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'HẾT HẠN',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _expiry,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // 2. INPUT FORM
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Số thẻ
                    TextFormField(
                      controller: _cardNumberController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      textCapitalization: TextCapitalization.none,
                      autocorrect: false,
                      enableSuggestions: false,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CardNumberInputFormatter(),
                      ],
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.credit_card_rounded),
                        labelText: 'Số thẻ tín dụng',
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF1E1E1E)
                            : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Colors.redAccent,
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập số thẻ';
                        }
                        final digits = value.replaceAll(' ', '');
                        if (digits.length != 16) {
                          return 'Số thẻ phải chứa đúng 16 chữ số';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Tên chủ thẻ
                    TextFormField(
                      controller: _cardHolderController,
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      textCapitalization: TextCapitalization.characters,
                      autocorrect: false,
                      enableSuggestions: false,
                      inputFormatters: [
                        FilteringTextInputFormatter.singleLineFormatter,
                      ],
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_rounded),
                        labelText: 'Họ và tên chủ thẻ (Không dấu)',
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF1E1E1E)
                            : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Colors.redAccent,
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên chủ thẻ';
                        }
                        if (value.trim().length < 3) {
                          return 'Họ tên quá ngắn';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Ngày hết hạn & CVV (Hàng ngang)
                    Row(
                      children: [
                        // Ngày hết hạn
                        Expanded(
                          child: TextFormField(
                            controller: _expiryController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            textCapitalization: TextCapitalization.none,
                            autocorrect: false,
                            enableSuggestions: false,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              ExpiryDateInputFormatter(),
                            ],
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.calendar_month_rounded,
                              ),
                              labelText: 'Ngày hết hạn (MM/YY)',
                              labelStyle: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Colors.redAccent,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nhập MM/YY';
                              }
                              if (value.length != 5 || !value.contains('/')) {
                                return 'Sai định dạng';
                              }
                              final parts = value.split('/');
                              final month = int.tryParse(parts[0]);
                              if (month == null || month < 1 || month > 12) {
                                return 'Tháng 01-12';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),

                        // CVV
                        Expanded(
                          child: TextFormField(
                            controller: _cvvController,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            textCapitalization: TextCapitalization.none,
                            autocorrect: false,
                            enableSuggestions: false,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.security_rounded),
                              labelText: 'Mã bí mật (CVV)',
                              labelStyle: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Colors.redAccent,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nhập CVV';
                              }
                              if (value.trim().length != 3) {
                                return 'Yêu cầu 3 số';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // Nút xác nhận thêm thẻ
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final rawCardNum = _cardNumberController.text
                                .replaceAll(' ', '');
                            // Mask card number
                            final maskedCardNo =
                                '•••• •••• •••• ${rawCardNum.substring(12)}';

                            final bool isMaster =
                                rawCardNum.startsWith('5') ||
                                rawCardNum.startsWith('2');
                            final String cardBrand = isMaster
                                ? 'mastercard'
                                : 'visa';
                            final String cardBrandName = isMaster
                                ? 'Mastercard'
                                : 'Visa';

                            authController.addPaymentMethod({
                              'id': DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                              'type': 'visa',
                              'cardNo': maskedCardNo,
                              'cardBrand': cardBrand,
                              'cardHolder': _cardHolderController.text
                                  .trim()
                                  .toUpperCase(),
                              'expiry': _expiryController.text.trim(),
                              'isDefault': false,
                              'gradientColors': isMaster
                                  ? [
                                      0xFFC33764,
                                      0xFF1D2671,
                                    ] // Purple-Red for Mastercard
                                  : [
                                      0xFF0F2027,
                                      0xFF203A43,
                                      0xFF2C5364,
                                    ], // Blue-Teal for Visa
                            });

                            Get.back();
                            Get.snackbar(
                              'Thành công',
                              'Đã liên kết thẻ $cardBrandName mới thành công!',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          }
                        },
                        child: const Text(
                          'THÊM THẺ THANH TOÁN',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// CUSTOM FORMATTERS FOR ACCURATE PREMIUM MASKING
// ----------------------------------------------------

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(' ', '');
    if (text.length > 16) text = text.substring(0, 16);

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll('/', '');
    if (text.length > 4) text = text.substring(0, 4);

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex == 2 && nonZeroIndex != text.length) {
        buffer.write('/');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
