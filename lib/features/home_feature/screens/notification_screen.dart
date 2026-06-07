import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nhom4/features/home_feature/controllers/home_controller.dart';

class NotificationScreen extends StatelessWidget {
  // Danh sách thông báo lưu tạm (dùng chung với HomeController)
  final RxList<Movie> notifiedMovies = Get.find<HomeController>().newList;

  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Thông báo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Nút xóa lịch sử
          TextButton.icon(
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  backgroundColor: Colors.grey[900],
                  title: const Text('Xóa thông báo',
                      style: TextStyle(color: Colors.white)),
                  content: const Text('Xóa toàn bộ lịch sử thông báo?',
                      style: TextStyle(color: Colors.grey)),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Hủy',
                          style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () {
                        NotificationHistory.clear();
                        Get.back();
                      },
                      child: const Text('Xóa',
                          style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete_outline,
                color: Colors.redAccent, size: 18),
            label: const Text('Xóa tất cả',
                style: TextStyle(color: Colors.redAccent, fontSize: 13)),
          ),
        ],
      ),
      body: Obx(() {
        final history = NotificationHistory.list;
        if (history.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_outlined,
                    color: Colors.grey[700], size: 60),
                const SizedBox(height: 12),
                Text('Chưa có thông báo nào',
                    style: TextStyle(color: Colors.grey[600], fontSize: 15)),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: history.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, index) {
            // Hiển thị mới nhất trên đầu
            final movie = history[history.length - 1 - index];
            return _buildNotificationItem(movie);
          },
        );
      }),
    );
  }

  Widget _buildNotificationItem(Movie movie) {
    return GestureDetector(
      onTap: () => Get.toNamed('/detail', arguments: movie),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Row(
          children: [
            // Ảnh phim
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: movie.thumbUrl.isNotEmpty
                  ? Image.network(
                      movie.thumbUrl,
                      width: 60,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 80,
                        color: Colors.grey[800],
                        child: const Icon(Icons.movie, color: Colors.grey),
                      ),
                    )
                  : Container(
                      width: 60,
                      height: 80,
                      color: Colors.grey[800],
                      child: const Icon(Icons.movie, color: Colors.grey),
                    ),
            ),
            const SizedBox(width: 12),

            // Thông tin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('MỚI',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      const Text('Phim mới cập nhật',
                          style:
                              TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    movie.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 13),
                      const SizedBox(width: 3),
                      Text(
                        movie.rating > 0
                            ? movie.rating.toStringAsFixed(1)
                            : 'N/A',
                        style: const TextStyle(
                            color: Colors.amber, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// Lưu lịch sử thông báo toàn cục
class NotificationHistory {
  static final RxList<Movie> list = <Movie>[].obs;

  static void add(Movie movie) {
    // Tránh trùng
    if (!list.any((m) => m.slug == movie.slug)) {
      list.add(movie);
    }
  }

  static void clear() => list.clear();
}