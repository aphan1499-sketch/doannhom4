import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/demo_payment_method_service.dart';

class ManagePaymentMethodsScreen extends StatefulWidget {
  const ManagePaymentMethodsScreen({super.key});

  @override
  State<ManagePaymentMethodsScreen> createState() =>
      _ManagePaymentMethodsScreenState();
}

class _ManagePaymentMethodsScreenState
    extends State<ManagePaymentMethodsScreen> {
  List<DemoPaymentMethod> _methods = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMethods();
  }

  Future<void> _loadMethods() async {
    final methods = await DemoPaymentMethodService.loadMethods();
    if (!mounted) return;
    setState(() {
      _methods = methods;
      _isLoading = false;
    });
  }

  Future<void> _setDefault(DemoPaymentMethod method) async {
    await DemoPaymentMethodService.setDefault(method.id);
    await _loadMethods();
    Get.snackbar(
      'Đã cập nhật',
      '${method.title} đã được đặt làm phương thức mặc định.',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
    );
  }

  Future<void> _removeMethod(DemoPaymentMethod method) async {
    await DemoPaymentMethodService.remove(method.id);
    await _loadMethods();
    Get.snackbar(
      'Đã xoá',
      'Đã huỷ liên kết ${method.title}.',
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
    );
  }

  void _showActionBottomSheet(DemoPaymentMethod method) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF121214),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                method.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                method.maskedValue,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              if (!method.isDefault) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.star_outline_rounded,
                    color: Colors.amber,
                  ),
                  title: const Text(
                    'Đặt làm mặc định',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  onTap: () {
                    Get.back();
                    _setDefault(method);
                  },
                ),
                const Divider(color: Colors.white10, height: 1),
              ],
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  'Huỷ liên kết',
                  style: TextStyle(color: Colors.redAccent, fontSize: 14),
                ),
                onTap: () {
                  Get.back();
                  _removeMethod(method);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddPaymentMethodBottomSheet() async {
    final request = await showModalBottomSheet<AddPaymentMethodRequest>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddPaymentMethodBottomSheet(),
    );

    if (request == null) return;

    setState(() {
      _isLoading = true;
    });

    if (request.type == DemoPaymentMethodType.card) {
      await DemoPaymentMethodService.addCard(
        cardNumber: request.cardNumber,
        expiryDate: request.expiryDate,
      );
    } else {
      await DemoPaymentMethodService.addWallet(
        type: request.type,
        phoneNumber: request.phoneNumber,
      );
    }

    await _loadMethods();
    Get.snackbar(
      'Thành công',
      'Đã thêm phương thức thanh toán demo.',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
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
          'Phương thức thanh toán',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quản lý các thẻ và ví điện tử dùng để gia hạn gói VIP của bạn.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDefaultSummary(),
                  const SizedBox(height: 20),
                  if (_methods.isEmpty)
                    _buildEmptyState()
                  else
                    ..._methods.map(
                      (method) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: PaymentMethodCard(
                          method: method,
                          onMorePressed: () => _showActionBottomSheet(method),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.amber,
                        side: BorderSide(
                          color: Colors.amber.withOpacity(0.45),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _showAddPaymentMethodBottomSheet,
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text(
                        'Thêm phương thức thanh toán mới',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDefaultSummary() {
    final defaultMethod = _methods
        .where((method) => method.isDefault)
        .cast<DemoPaymentMethod?>()
        .firstOrNull;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151516),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              color: Colors.amber,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thanh toán VIP mặc định',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  defaultMethod == null
                      ? 'Chưa có phương thức thanh toán'
                      : '${defaultMethod.title} - ${defaultMethod.maskedValue}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: const Color(0xFF121214),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: const Column(
        children: [
          Icon(Icons.credit_card_off_rounded, color: Colors.grey, size: 42),
          SizedBox(height: 12),
          Text(
            'Bạn chưa liên kết phương thức thanh toán',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            'Thêm thẻ hoặc ví điện tử demo để dùng cho gói VIP.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({
    super.key,
    required this.method,
    required this.onMorePressed,
  });

  final DemoPaymentMethod method;
  final VoidCallback onMorePressed;

  @override
  Widget build(BuildContext context) {
    final colors = _gradientFor(method.type);

    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -20,
            child: Icon(
              method.type == DemoPaymentMethodType.card
                  ? Icons.credit_card_rounded
                  : Icons.account_balance_wallet_rounded,
              size: 120,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLogo(method.type),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white70),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onMorePressed,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                method.maskedValue,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      method.expiryDate == null
                          ? method.status
                          : 'Hạn dùng: ${method.expiryDate}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (method.isDefault) const _DefaultBadge(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static List<Color> _gradientFor(DemoPaymentMethodType type) {
    switch (type) {
      case DemoPaymentMethodType.card:
        return const [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)];
      case DemoPaymentMethodType.momo:
        return const [Color(0xFF800045), Color(0xFFA50064)];
      case DemoPaymentMethodType.zalopay:
        return const [Color(0xFF005BAA), Color(0xFF00A25B)];
    }
  }

  static Widget _buildLogo(DemoPaymentMethodType type) {
    switch (type) {
      case DemoPaymentMethodType.card:
        return const Text(
          'VISA',
          style: TextStyle(
            color: Colors.white,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        );
      case DemoPaymentMethodType.momo:
        return _WalletLogo(label: 'momo', color: Color(0xFFA50064));
      case DemoPaymentMethodType.zalopay:
        return _WalletLogo(label: 'ZaloPay', color: Color(0xFF0088FF));
    }
  }
}

class _DefaultBadge extends StatelessWidget {
  const _DefaultBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.greenAccent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.greenAccent, size: 10),
          SizedBox(width: 4),
          Text(
            'MẶC ĐỊNH',
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletLogo extends StatelessWidget {
  const _WalletLogo({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

class AddPaymentMethodRequest {
  const AddPaymentMethodRequest({
    required this.type,
    this.cardNumber = '',
    this.expiryDate = '',
    this.phoneNumber = '',
  });

  final DemoPaymentMethodType type;
  final String cardNumber;
  final String expiryDate;
  final String phoneNumber;
}

class AddPaymentMethodBottomSheet extends StatefulWidget {
  const AddPaymentMethodBottomSheet({super.key});

  @override
  State<AddPaymentMethodBottomSheet> createState() =>
      _AddPaymentMethodBottomSheetState();
}

class _AddPaymentMethodBottomSheetState
    extends State<AddPaymentMethodBottomSheet> {
  int _selectedWalletIndex = 0;
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(
    text: '0981234321',
  );

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitCard() {
    final digits = _cardNumberController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 12 || _expiryController.text.trim().isEmpty) {
      Get.snackbar(
        'Thiếu thông tin',
        'Vui lòng nhập số thẻ demo và hạn dùng.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    Navigator.pop(
      context,
      AddPaymentMethodRequest(
        type: DemoPaymentMethodType.card,
        cardNumber: _cardNumberController.text,
        expiryDate: _expiryController.text.trim(),
      ),
    );
  }

  void _submitWallet() {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9) {
      Get.snackbar(
        'Thiếu thông tin',
        'Vui lòng nhập số điện thoại ví demo.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    Navigator.pop(
      context,
      AddPaymentMethodRequest(
        type: _selectedWalletIndex == 0
            ? DemoPaymentMethodType.momo
            : DemoPaymentMethodType.zalopay,
        phoneNumber: _phoneController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: 24 + keyboardPadding,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF121214),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Thêm phương thức thanh toán',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TabBar(
              indicatorColor: Colors.amber,
              labelColor: Colors.amber,
              unselectedLabelColor: Colors.grey,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.white10,
              tabs: const [
                Tab(
                  icon: Icon(Icons.credit_card_rounded, size: 20),
                  text: 'Thẻ',
                ),
                Tab(
                  icon: Icon(Icons.account_balance_wallet_rounded, size: 20),
                  text: 'Ví điện tử',
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 288,
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [_buildCardFormTab(), _buildWalletTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFormTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _cardNumberController,
          label: 'Số thẻ demo',
          hint: '4111 1111 1111 4242',
          keyboardType: TextInputType.number,
          icon: Icons.payment,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _expiryController,
                label: 'Hết hạn',
                hint: '12/28',
                keyboardType: TextInputType.datetime,
                icon: Icons.calendar_today,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _cvvController,
                label: 'CVV',
                hint: '123',
                obscureText: true,
                keyboardType: TextInputType.number,
                icon: Icons.lock_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Demo chỉ lưu 4 số cuối và hạn dùng, không lưu số thẻ đầy đủ.',
          style: TextStyle(color: Colors.grey, fontSize: 11, height: 1.4),
        ),
        const Spacer(),
        _buildPrimaryButton('Lưu thẻ demo', _submitCard),
      ],
    );
  }

  Widget _buildWalletTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWalletChoiceTile(
          index: 0,
          title: 'Ví điện tử MoMo',
          iconText: 'momo',
          logoBgColor: const Color(0xFFA50064),
        ),
        const SizedBox(height: 12),
        _buildWalletChoiceTile(
          index: 1,
          title: 'Ví điện tử ZaloPay',
          iconText: 'Zalo',
          logoBgColor: const Color(0xFF0088FF),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Số điện thoại demo',
          hint: '0981234321',
          keyboardType: TextInputType.phone,
          icon: Icons.phone_android_rounded,
        ),
        const Spacer(),
        _buildPrimaryButton('Liên kết ví demo', _submitWallet),
      ],
    );
  }

  Widget _buildPrimaryButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.amber, size: 18),
        filled: true,
        fillColor: const Color(0xFF1E1E22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildWalletChoiceTile({
    required int index,
    required String title,
    required String iconText,
    required Color logoBgColor,
  }) {
    final isSelected = _selectedWalletIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedWalletIndex = index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E1C18) : const Color(0xFF1E1E22),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.transparent,
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Colors.amber : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: logoBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                iconText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
