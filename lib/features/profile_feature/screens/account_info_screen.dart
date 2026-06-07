import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AccountInfoScreen extends StatelessWidget {
  AccountInfoScreen({super.key});

  final AuthController authController = Get.find<AuthController>();

  static const Color _red = Color(0xFFE52D27);

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _background(BuildContext context) =>
      _isDark(context) ? const Color(0xFF0B0B0C) : const Color(0xFFF6F6F7);

  Color _card(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1C1C1E) : Colors.white;

  Color _primaryText(BuildContext context) =>
      _isDark(context) ? Colors.white : const Color(0xFF171717);

  Color _secondaryText(BuildContext context) =>
      _isDark(context) ? Colors.grey.shade500 : Colors.grey.shade600;

  Color _line(BuildContext context) => _isDark(context)
      ? Colors.white.withOpacity(0.06)
      : Colors.black.withOpacity(0.06);

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }

  Widget _avatarImage(String source, String initials) {
    final fallback = Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 38,
          fontWeight: FontWeight.w900,
        ),
      ),
    );

    if (source.startsWith('http')) {
      return Image.network(
        source,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }

    return Image.asset(
      source,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }

  void _editText(
    BuildContext context, {
    required String title,
    required String field,
    required String currentValue,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final controller = TextEditingController(text: currentValue);
    Get.defaultDialog(
      title: title,
      titleStyle: TextStyle(
        color: _primaryText(context),
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: _card(context),
      radius: 14,
      contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
      content: TextField(
        controller: controller,
        keyboardType: keyboardType,
        autofocus: true,
        style: TextStyle(color: _primaryText(context)),
        decoration: InputDecoration(
          hintText: title,
          hintStyle: TextStyle(color: _secondaryText(context)),
          filled: true,
          fillColor: _isDark(context)
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.04),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
          ),
        ),
      ),
      textCancel: 'Hủy',
      textConfirm: 'Lưu',
      confirmTextColor: Colors.white,
      cancelTextColor: _secondaryText(context),
      buttonColor: _red,
      onConfirm: () {
        final text = controller.text.trim();
        if (text.isEmpty) {
          Get.snackbar(
            'Lỗi',
            'Vui lòng không để trống.',
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          return;
        }
        if (field == 'email' && !GetUtils.isEmail(text)) {
          Get.snackbar(
            'Lỗi',
            'Email không hợp lệ.',
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          return;
        }
        Get.back();
        authController.updateUserInfo(field, text);
      },
    );
  }

  void _pickGender(BuildContext context) {
    final genders = ['Nam', 'Nữ', 'Không tiết lộ'];
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        decoration: BoxDecoration(
          color: _card(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn giới tính',
              style: TextStyle(
                color: _primaryText(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...genders.map(
              (gender) => Obx(
                () => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    gender,
                    style: TextStyle(color: _primaryText(context)),
                  ),
                  trailing: authController.userGender.value == gender
                      ? const Icon(Icons.check_circle, color: Colors.redAccent)
                      : Icon(
                          Icons.circle_outlined,
                          color: _secondaryText(context),
                        ),
                  onTap: () {
                    Get.back();
                    authController.updateUserInfo('gender', gender);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  void _pickAvatar(BuildContext context) {
    final avatars = [
      'assets/images/1.png',
      'assets/images/2.png',
      'assets/images/3.png',
      'assets/images/4.png',
      'assets/images/5.png',
      'assets/images/6.png',
    ];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        decoration: BoxDecoration(
          color: _card(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn ảnh đại diện',
              style: TextStyle(
                color: _primaryText(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              itemCount: avatars.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemBuilder: (sheetContext, index) {
                final avatar = avatars[index];
                return Obx(
                  () => InkWell(
                    onTap: () {
                      Get.back();
                      authController.updateUserInfo('avatar', avatar);
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: authController.userAvatar.value == avatar
                              ? Colors.redAccent
                              : _line(context),
                          width: authController.userAvatar.value == avatar
                              ? 2
                              : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          avatar,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: _line(context),
                                child: Icon(
                                  Icons.person,
                                  color: _primaryText(context),
                                ),
                              ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _avatar(BuildContext context) {
    return Obx(() {
      final initials = _initials(authController.currentUser.value);
      return Center(
        child: InkWell(
          onTap: () => _pickAvatar(context),
          borderRadius: BorderRadius.circular(80),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE52D27), Color(0xFFB31217)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.28),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _avatarImage(
                    authController.userAvatar.value,
                    initials,
                  ),
                ),
              ),
              Positioned(
                right: 2,
                bottom: 4,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _red,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _infoCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: _card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line(context)),
        boxShadow: [
          if (!_isDark(context))
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider(BuildContext context) {
    return Divider(height: 1, indent: 70, endIndent: 16, color: _line(context));
  }

  Widget _fieldTile(
    BuildContext context, {
    required String title,
    required RxString value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Obx(
      () => ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.redAccent, size: 21),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: _primaryText(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          value.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: _secondaryText(context), fontSize: 13),
        ),
        trailing: Icon(
          Icons.edit_outlined,
          color: _secondaryText(context),
          size: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background(context),
      appBar: AppBar(
        title: const Text('Thông tin tài khoản'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: _primaryText(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 34),
          child: Column(
            children: [
              _avatar(context),
              const SizedBox(height: 18),
              Obx(
                () => Text(
                  authController.currentUser.value,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(context),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Obx(
                () => Text(
                  authController.userEmail.value,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _secondaryText(context)),
                ),
              ),
              const SizedBox(height: 28),
              _infoCard(context, [
                _fieldTile(
                  context,
                  title: 'Họ và tên',
                  value: authController.currentUser,
                  icon: Icons.person_outline_rounded,
                  onTap: () => _editText(
                    context,
                    title: 'Họ và tên',
                    field: 'name',
                    currentValue: authController.currentUser.value,
                  ),
                ),
                _divider(context),
                _fieldTile(
                  context,
                  title: 'Email',
                  value: authController.userEmail,
                  icon: Icons.email_outlined,
                  onTap: () => _editText(
                    context,
                    title: 'Email',
                    field: 'email',
                    currentValue: authController.userEmail.value,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                _divider(context),
                _fieldTile(
                  context,
                  title: 'Số điện thoại',
                  value: authController.userPhone,
                  icon: Icons.phone_android_rounded,
                  onTap: () => _editText(
                    context,
                    title: 'Số điện thoại',
                    field: 'phone',
                    currentValue:
                        authController.userPhone.value == 'Chưa cập nhật'
                        ? ''
                        : authController.userPhone.value,
                    keyboardType: TextInputType.phone,
                  ),
                ),
                _divider(context),
                _fieldTile(
                  context,
                  title: 'Ngày sinh',
                  value: authController.userBirthDate,
                  icon: Icons.calendar_today_outlined,
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      authController.updateUserInfo(
                        'dob',
                        '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}',
                      );
                    }
                  },
                ),
                _divider(context),
                _fieldTile(
                  context,
                  title: 'Giới tính',
                  value: authController.userGender,
                  icon: Icons.wc_outlined,
                  onTap: () => _pickGender(context),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
