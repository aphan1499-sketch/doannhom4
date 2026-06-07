import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nhom4/features/home_feature/controllers/home_controller.dart';

// ─────────────────────────────────────────────────────────────
//  NotificationHistory  –  lưu đề xuất phim theo ngày
// ─────────────────────────────────────────────────────────────
class NotificationHistory {
  // Key lưu trong SharedPreferences
  static const _keyDate = 'notif_date';       // ngày đã generate (yyyy-MM-dd)
  static const _keySlugs = 'notif_slugs';     // slug 3 phim, cách nhau ','

  /// Danh sách 3 phim đề xuất hôm nay (observable để Obx tự rebuild)
  static final RxList<Movie> dailyMovies = <Movie>[].obs;

  /// Gọi khi app khởi động hoặc khi mở màn hình thông báo.
  /// Nếu hôm nay chưa có đề xuất → random 3 phim từ [allMovies] và lưu.
  /// Nếu đã có → load lại từ SharedPreferences.
  static Future<void> refreshIfNeeded(List<Movie> allMovies) async {
    if (allMovies.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final savedDate = prefs.getString(_keyDate) ?? '';

    if (savedDate == today) {
      // Hôm nay đã có đề xuất → load lại theo slug đã lưu
      final savedSlugs = (prefs.getString(_keySlugs) ?? '').split(',');
      final loaded = savedSlugs
          .map((slug) => allMovies.firstWhereOrNull((m) => m.slug == slug))
          .whereType<Movie>()
          .toList();

      if (loaded.isNotEmpty) {
        dailyMovies.assignAll(loaded);
        return;
      }
      // Nếu slug không khớp (phim đã hết trong api) → generate lại
    }

    // Ngày mới hoặc chưa có → random 3 phim
    final picks = _pickRandom(allMovies, 3);
    dailyMovies.assignAll(picks);

    // Lưu vào SharedPreferences
    await prefs.setString(_keyDate, today);
    await prefs.setString(_keySlugs, picks.map((m) => m.slug).join(','));
  }

  /// Xóa thủ công (nút "Làm mới đề xuất" – debug / UX)
  static Future<void> clearAndRefresh(List<Movie> allMovies) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDate);
    await prefs.remove(_keySlugs);
    await refreshIfNeeded(allMovies);
  }

  // ── Helpers ──────────────────────────────────────────────

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static List<Movie> _pickRandom(List<Movie> source, int count) {
    final pool = List<Movie>.from(source);
    pool.shuffle(Random());
    return pool.take(count).toList();
  }
}

// ─────────────────────────────────────────────────────────────
//  NotificationScreen
// ─────────────────────────────────────────────────────────────
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final HomeController _homeController = Get.find<HomeController>();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    // Load / generate đề xuất ngay khi mở màn hình
    _load();
  }

  Future<void> _load() async {
    await NotificationHistory.refreshIfNeeded(_homeController.newList);
  }

  Future<void> _forceRefresh() async {
    setState(() => _isRefreshing = true);
    await NotificationHistory.clearAndRefresh(_homeController.newList);
    setState(() => _isRefreshing = false);
  }

  // Ngày hôm nay hiển thị kiểu "Thứ X, DD/MM/YYYY"
  String get _todayLabel {
    final now = DateTime.now();
    const weekdays = [
      'Thứ Hai', 'Thứ Ba', 'Thứ Tư',
      'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật'
    ];
    final wd = weekdays[now.weekday - 1];
    return '$wd, ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

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
          // Nút làm mới (debug / cho phép người dùng refresh thủ công)
          IconButton(
            tooltip: 'Làm mới đề xuất',
            onPressed: _isRefreshing ? null : _forceRefresh,
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.redAccent, strokeWidth: 2),
                  )
                : const Icon(Icons.refresh, color: Colors.white70, size: 20),
          ),
        ],
      ),
      body: Obx(() {
        final movies = NotificationHistory.dailyMovies;

        if (movies.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.redAccent),
          );
        }

        return CustomScrollView(
          slivers: [
            // ── Header "Đề xuất hôm nay" ──
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),

            // ── 3 card phim đề xuất (dọc, giống YouTube) ──
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildMovieCard(movies[index], index + 1),
                childCount: movies.length,
              ),
            ),

            // ── Footer note ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.grey, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Đề xuất được làm mới mỗi ngày',
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ── Header ───────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 12, 15, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.redAccent.withOpacity(0.15), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_fire_department,
                color: Colors.redAccent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🎬 Đề xuất hôm nay cho bạn',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _todayLabel,
                  style:
                      TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          // Badge số lượng
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '3 phim',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ── Movie card (kiểu YouTube) ─────────────────────────────

  Widget _buildMovieCard(Movie movie, int rank) {
    return GestureDetector(
      onTap: () => Get.toNamed('/detail', arguments: movie),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail wide (16:9 style) ──
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(14)),
                  child: AspectRatio(
                    aspectRatio: 16 / 7,
                    child: movie.posterUrl.isNotEmpty
                        ? Image.network(
                            movie.posterUrl.replaceAll('w300', 'w780'),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.network(
                              movie.thumbUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _placeholderBox(),
                            ),
                          )
                        : Image.network(
                            movie.thumbUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _placeholderBox(),
                          ),
                  ),
                ),
                // Gradient overlay bên dưới thumbnail
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(14)),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.55),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                // Badge số thứ tự
                Positioned(
                  top: 10,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#$rank ĐỀ XUẤT',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Play button ở giữa
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow,
                          color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ],
            ),

            // ── Info row (thumbnail kèm text, giống YouTube) ──
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail nhỏ bên trái
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      movie.thumbUrl,
                      width: 52,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 52,
                        height: 70,
                        color: Colors.grey[800],
                        child: const Icon(Icons.movie, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Thông tin
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tiêu đề phim
                        Text(
                          movie.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),

                        // Rating + label "Phim đề xuất"
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 13),
                            const SizedBox(width: 3),
                            Text(
                              movie.rating > 0
                                  ? movie.rating.toStringAsFixed(1)
                                  : 'N/A',
                              style: const TextStyle(
                                  color: Colors.amber, fontSize: 12),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.15),
                                border: Border.all(
                                    color: Colors.redAccent.withOpacity(0.4)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Gợi ý',
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Nút xem ngay
                        GestureDetector(
                          onTap: () =>
                              Get.toNamed('/detail', arguments: movie),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.play_arrow,
                                    color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text('Xem ngay',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderBox() => Container(
        color: Colors.grey[850],
        child: const Center(
            child: Icon(Icons.movie, color: Colors.grey, size: 36)),
      );
}