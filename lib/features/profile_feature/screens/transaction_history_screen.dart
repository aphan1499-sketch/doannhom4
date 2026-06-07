import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/transaction_cache_service.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

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

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return _formatDateTime(date);
  }

  String _formatDateFromMillis(dynamic millis) {
    if (millis is! int) return 'N/A';
    return _formatDateTime(DateTime.fromMillisecondsSinceEpoch(millis));
  }

  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  String _formatCurrency(num amount) {
    return '${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')} đ';
  }

  Timestamp? _timestampFrom(dynamic value) {
    if (value is Timestamp) return value;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: _background(context),
      appBar: AppBar(
        backgroundColor: _card(context),
        elevation: 0,
        foregroundColor: _primaryText(context),
        title: const Text(
          'Lịch sử giao dịch',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: currentUser == null
          ? _buildRequireLoginState(context)
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .where('userId', isEqualTo: currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildCachedHistory(context, currentUser.uid);
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) return _buildEmptyState(context);

                final sortedDocs = List<QueryDocumentSnapshot>.from(docs)
                  ..sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;
                    final aTime = _timestampFrom(aData['createdAt']);
                    final bTime = _timestampFrom(bData['createdAt']);
                    if (aTime == null && bTime == null) return 0;
                    if (aTime == null) return 1;
                    if (bTime == null) return -1;
                    return bTime.compareTo(aTime);
                  });

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: sortedDocs.length,
                  itemBuilder: (context, index) {
                    final data =
                        sortedDocs[index].data() as Map<String, dynamic>;
                    return _buildTransactionCard(context, data);
                  },
                );
              },
            ),
    );
  }

  Widget _buildRequireLoginState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _stateIcon(context, Icons.person_outline, Colors.grey),
            const SizedBox(height: 24),
            Text(
              'Yêu cầu đăng nhập',
              style: TextStyle(
                color: _primaryText(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vui lòng đăng nhập tài khoản để quản lý lịch sử thanh toán.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _secondaryText(context), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _stateIcon(context, Icons.receipt_long_outlined, Colors.amber),
            const SizedBox(height: 24),
            Text(
              'Chưa có giao dịch nào',
              style: TextStyle(
                color: _primaryText(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Các giao dịch nâng cấp tài khoản VIP của bạn sẽ xuất hiện tại đây.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _secondaryText(context), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCachedHistory(BuildContext context, String userId) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: TransactionCacheService.loadTransactions(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.amber),
          );
        }

        final transactions = snapshot.data ?? [];
        if (transactions.isEmpty) {
          return _buildPermissionState(context);
        }

        transactions.sort((a, b) {
          final aTime = a['createdAtMillis'] as int? ?? 0;
          final bTime = b['createdAtMillis'] as int? ?? 0;
          return bTime.compareTo(aTime);
        });

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            return _buildTransactionCard(context, transactions[index]);
          },
        );
      },
    );
  }

  Widget _buildPermissionState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _stateIcon(context, Icons.lock_outline, Colors.redAccent),
            const SizedBox(height: 24),
            Text(
              'Chưa thể đọc lịch sử',
              style: TextStyle(
                color: _primaryText(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Firestore chưa cho phép đọc collection bookings. Các giao dịch mới sẽ được lưu tạm trên máy và hiển thị tại đây.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _secondaryText(context), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stateIcon(BuildContext context, IconData icon, Color color) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(color: _line(context), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 40),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final packageName =
        (data['movieTitle'] ?? data['packageName'] ?? 'VIP Premium Package')
            .toString();
    final amount = (data['amount'] as num?) ?? 0;
    final orderId = (data['orderId'] ?? 'N/A').toString();
    final status = (data['status'] ?? 'pending').toString();
    final formattedDate =
        _formatDate(_timestampFrom(data['createdAt'])) == 'N/A'
        ? _formatDateFromMillis(data['createdAtMillis'])
        : _formatDate(_timestampFrom(data['createdAt']));
    final formattedPrice = _formatCurrency(amount);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _card(context),
        borderRadius: BorderRadius.circular(16),
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  packageName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(context),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildStatusBadge(status),
            ],
          ),
          const SizedBox(height: 16),
          _buildRowDetail(context, 'Mã đơn hàng', orderId),
          const SizedBox(height: 8),
          _buildRowDetail(context, 'Thời gian', formattedDate),
          Divider(height: 24, color: _line(context)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng tiền',
                style: TextStyle(color: _secondaryText(context), fontSize: 13),
              ),
              Text(
                formattedPrice,
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRowDetail(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: _secondaryText(context), fontSize: 13),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _primaryText(context).withOpacity(0.78),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    String text = 'Chờ xử lý';
    Color color = Colors.orange;
    Color bgColor = Colors.orange.withOpacity(0.1);

    if (status == 'success') {
      text = 'Thành công';
      color = Colors.green;
      bgColor = Colors.green.withOpacity(0.1);
    } else if (status == 'failed' || status == 'cancelled') {
      text = 'Thất bại';
      color = Colors.redAccent;
      bgColor = Colors.redAccent.withOpacity(0.1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
