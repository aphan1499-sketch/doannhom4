import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

enum SubscriptionPaymentMethodType { card, momo, zalopay }

class SubscriptionPaymentMethod {
  const SubscriptionPaymentMethod({
    required this.id,
    required this.type,
    required this.title,
    required this.maskedValue,
    required this.status,
    required this.isDefault,
    this.expiryDate,
  });

  final String id;
  final SubscriptionPaymentMethodType type;
  final String title;
  final String maskedValue;
  final String status;
  final bool isDefault;
  final String? expiryDate;

  SubscriptionPaymentMethod copyWith({
    String? id,
    SubscriptionPaymentMethodType? type,
    String? title,
    String? maskedValue,
    String? status,
    bool? isDefault,
    String? expiryDate,
  }) {
    return SubscriptionPaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      maskedValue: maskedValue ?? this.maskedValue,
      status: status ?? this.status,
      isDefault: isDefault ?? this.isDefault,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'maskedValue': maskedValue,
      'status': status,
      'isDefault': isDefault,
      'expiryDate': expiryDate,
    };
  }

  factory SubscriptionPaymentMethod.fromJson(Map<String, dynamic> json) {
    return SubscriptionPaymentMethod(
      id: json['id'] as String,
      type: SubscriptionPaymentMethodType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => SubscriptionPaymentMethodType.card,
      ),
      title: json['title'] as String,
      maskedValue: json['maskedValue'] as String,
      status: json['status'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
      expiryDate: json['expiryDate'] as String?,
    );
  }
}

class SubscriptionPaymentMethodService {
  static const String _storageKey = 'subscription_payment_methods_v1';

  static Future<List<SubscriptionPaymentMethod>> loadMethods() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      final seeded = _seedMethods();
      await _saveMethods(seeded);
      return seeded;
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final methods = decoded
          .map(
            (item) => SubscriptionPaymentMethod.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
      return _ensureOneDefault(methods);
    } catch (_) {
      final seeded = _seedMethods();
      await _saveMethods(seeded);
      return seeded;
    }
  }

  static Future<void> addCard({
    required String cardNumber,
    required String expiryDate,
  }) async {
    final methods = await loadMethods();
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    final last4 = digits.length >= 4
        ? digits.substring(digits.length - 4)
        : '4242';
    final isFirstMethod = methods.isEmpty;

    methods.add(
      SubscriptionPaymentMethod(
        id: 'card_${DateTime.now().millisecondsSinceEpoch}',
        type: SubscriptionPaymentMethodType.card,
        title: 'Thẻ Visa/MasterCard',
        maskedValue: '••••  ••••  ••••  $last4',
        expiryDate: expiryDate,
        status: 'Đã xác thực',
        isDefault: isFirstMethod,
      ),
    );

    await _saveMethods(_ensureOneDefault(methods));
  }

  static Future<void> addWallet({
    required SubscriptionPaymentMethodType type,
    required String phoneNumber,
  }) async {
    final methods = await loadMethods();
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final prefix = digits.length >= 3 ? digits.substring(0, 3) : '098';
    final suffix = digits.length >= 3
        ? digits.substring(digits.length - 3)
        : '321';
    final isFirstMethod = methods.isEmpty;
    final isMomo = type == SubscriptionPaymentMethodType.momo;

    methods.add(
      SubscriptionPaymentMethod(
        id: '${type.name}_${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        title: isMomo ? 'Ví điện tử MoMo' : 'Ví điện tử ZaloPay',
        maskedValue: '$prefix••••$suffix',
        status: 'Đã liên kết',
        isDefault: isFirstMethod,
      ),
    );

    await _saveMethods(_ensureOneDefault(methods));
  }

  static Future<void> setDefault(String id) async {
    final methods = await loadMethods();
    await _saveMethods(
      methods
          .map((method) => method.copyWith(isDefault: method.id == id))
          .toList(),
    );
  }

  static Future<void> remove(String id) async {
    final methods = await loadMethods();
    final filtered = methods.where((method) => method.id != id).toList();
    await _saveMethods(_ensureOneDefault(filtered));
  }

  static Future<void> _saveMethods(
    List<SubscriptionPaymentMethod> methods,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(methods.map((method) => method.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }

  static List<SubscriptionPaymentMethod> _ensureOneDefault(
    List<SubscriptionPaymentMethod> methods,
  ) {
    if (methods.isEmpty) return methods;
    if (methods.any((method) => method.isDefault)) return methods;

    return [methods.first.copyWith(isDefault: true), ...methods.skip(1)];
  }

  static List<SubscriptionPaymentMethod> _seedMethods() {
    return const [
      SubscriptionPaymentMethod(
        id: 'seed_card_4242',
        type: SubscriptionPaymentMethodType.card,
        title: 'Thẻ Visa/MasterCard',
        maskedValue: '••••  ••••  ••••  4242',
        expiryDate: '12/28',
        status: 'Đã xác thực',
        isDefault: true,
      ),
      SubscriptionPaymentMethod(
        id: 'seed_momo_321',
        type: SubscriptionPaymentMethodType.momo,
        title: 'Ví điện tử MoMo',
        maskedValue: '098••••321',
        status: 'Đã liên kết',
        isDefault: false,
      ),
    ];
  }
}
