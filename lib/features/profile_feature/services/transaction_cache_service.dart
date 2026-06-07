import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TransactionCacheService {
  static String _key(String userId) => 'transaction_history_$userId';

  static Future<void> saveTransaction({
    required String userId,
    required String orderId,
    required String packageName,
    required double amount,
    String status = 'pending',
    String? method,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final transactions = await loadTransactions(userId);
    final existingIndex = transactions.indexWhere(
      (item) => item['orderId'] == orderId,
    );
    final now = DateTime.now().millisecondsSinceEpoch;
    final record = {
      'orderId': orderId,
      'userId': userId,
      'movieTitle': packageName,
      'amount': amount,
      'status': status,
      'method': method,
      'createdAtMillis': existingIndex >= 0
          ? transactions[existingIndex]['createdAtMillis'] ?? now
          : now,
      'updatedAtMillis': now,
    };

    if (existingIndex >= 0) {
      transactions[existingIndex] = {...transactions[existingIndex], ...record};
    } else {
      transactions.insert(0, record);
    }

    await prefs.setString(_key(userId), jsonEncode(transactions));
  }

  static Future<void> updateStatus({
    required String userId,
    required String orderId,
    required String status,
  }) async {
    final transactions = await loadTransactions(userId);
    final index = transactions.indexWhere((item) => item['orderId'] == orderId);
    if (index < 0) return;

    transactions[index] = {
      ...transactions[index],
      'status': status,
      'updatedAtMillis': DateTime.now().millisecondsSinceEpoch,
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(userId), jsonEncode(transactions));
  }

  static Future<List<Map<String, dynamic>>> loadTransactions(
    String userId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(userId));
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
