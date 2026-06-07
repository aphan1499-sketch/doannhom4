import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LinkBankScreen extends StatefulWidget {
  const LinkBankScreen({super.key});

  @override
  State<LinkBankScreen> createState() => _LinkBankScreenState();
}

class _LinkBankScreenState extends State<LinkBankScreen> {
  final AuthController authController = Get.find<AuthController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _accountNoController = TextEditingController();
  final TextEditingController _accountHolderController = TextEditingController();

  final List<Map<String, dynamic>> _banks = [
    {
      'name': 'Vietcombank',
      'logoText': 'VCB',
      'color': const Color(0xFF007A33),
      'gradient': [0xFF007A33, 0xFF004B87],
    },
    {
      'name': 'Techcombank',
      'logoText': 'TCB',
      'color': const Color(0xFFED1C24),
      'gradient': [0xFFED1C24, 0xFF7A080D],
    },
    {
      'name': 'BIDV',
      'logoText': 'BIDV',
      'color': const Color(0xFF005AAB),
      'gradient': [0xFF005AAB, 0xFF009C59],
    },
    {
      'name': 'MB Bank',
      'logoText': 'MB',
      'color': const Color(0xFF0038A8),
      'gradient': [0xFF0038A8, 0xFF00C6FF],
    },
    {
      'name': 'ACB',
      'logoText': 'ACB',
      'color': const Color(0xFF0072BC),
      'gradient': [0xFF0072BC, 0xFF00C6FF],
    },
    {
      'name': 'VietinBank',
      'logoText': 'CTG',
      'color': const Color(0xFF00529B),
      'gradient': [0xFF00529B, 0xFF0092D1],
    },
  ];

  Map<String, dynamic>? _selectedBank;

  @override
  void initState() {
    super.initState();
    _selectedBank = _banks[0]; // Default selected bank
  }

  @override
  void dispose() {
    _accountNoController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text(
          'Liên kết Ngân hàng',
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
              
              // 1. CHỌN NGÂN HÀNG
              Text(
                'CHỌN NGÂN HÀNG LIÊN KẾT',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _banks.length,
                  itemBuilder: (context, index) {
                    final bank = _banks[index];
                    final isSelected = _selectedBank?['name'] == bank['name'];
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedBank = bank;
                        });
                      },
                      child: Container(
                        width: 90,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? bank['color'].withOpacity(0.15) 
                              : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? bank['color'] : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: bank['color'],
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  bank['logoText'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              bank['name'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 32),

              // 2. NHẬP THÔNG TIN TÀI KHOẢN
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Số tài khoản ngân hàng
                    TextFormField(
                      controller: _accountNoController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      textCapitalization: TextCapitalization.none,
                      autocorrect: false,
                      enableSuggestions: false,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                      ],
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.account_balance_rounded, color: _selectedBank?['color']),
                        labelText: 'Số tài khoản ngân hàng',
                        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: _selectedBank?['color'] ?? Colors.redAccent, width: 1.5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập số tài khoản';
                        }
                        if (value.trim().length < 8) {
                          return 'Số tài khoản không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Tên chủ tài khoản
                    TextFormField(
                      controller: _accountHolderController,
                      keyboardType: TextInputType.text,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      textCapitalization: TextCapitalization.characters,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        labelText: 'Họ và tên chủ tài khoản (Viết hoa không dấu)',
                        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: _selectedBank?['color'] ?? Colors.redAccent, width: 1.5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên chủ tài khoản';
                        }
                        if (value.trim().length < 3) {
                          return 'Họ tên quá ngắn';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 48),

                    // Nút xác nhận liên kết
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedBank?['color'] ?? Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate() && _selectedBank != null) {
                            final rawAcctNo = _accountNoController.text.trim();
                            // Mask bank account number
                            final maskedAcctNo = rawAcctNo.length >= 4 
                                ? '•••• •••• ${rawAcctNo.substring(rawAcctNo.length - 4)}'
                                : rawAcctNo;
                            
                            authController.addPaymentMethod({
                              'id': DateTime.now().millisecondsSinceEpoch.toString(),
                              'type': 'bank',
                              'bankName': _selectedBank!['name'],
                              'accountNo': maskedAcctNo,
                              'accountHolder': _accountHolderController.text.trim().toUpperCase(),
                              'isDefault': false,
                              'gradientColors': _selectedBank!['gradient'],
                            });

                            Get.back();
                            Get.snackbar(
                              'Thành công', 
                              'Đã liên kết tài khoản ngân hàng ${_selectedBank!['name']} thành công!',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          }
                        },
                        child: const Text(
                          'XÁC NHẬN LIÊN KẾT',
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
