import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nhom4/features/home_feature/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:nhom4/main_navigation/main_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController controller = Get.put(HomeController());
  static const _castChannel = MethodChannel('com.nhom4/cast');

  Future<void> _startCast() async {
    try {
      await _castChannel.invokeMethod('startScreenMirror');
    } catch (e) {
      Get.snackbar(
        '⚠️ Không thể Cast',
        'Thiết bị không hỗ trợ tính năng này',
        backgroundColor: Colors.grey[900],
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "MOVIE-APP",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cast, color: Colors.white),
            onPressed: _startCast,
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () => Get.toNamed('/notifications'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner carousel
            Obx(() {
              if (controller.newList.isEmpty) {
                return Container(
                  height: 260,
                  color: Colors.grey[900],
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.redAccent),
                  ),
                );
              }
              return _BannerCarousel(movies: controller.newList);
            }),

            // Danh sách phim
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: Colors.redAccent),
                  ),
                );
              }
              if (controller.hasError.value) {
                return Center(
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.redAccent, size: 40),
                      const SizedBox(height: 8),
                      const Text('Không tải được phim',
                          style: TextStyle(color: Colors.white)),
                      TextButton(
                        onPressed: controller.fetchNewMovies,
                        child: const Text('Thử lại',
                            style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  _buildMovieSection("🆕 Phim Mới Cập Nhật", controller.newList),
                  _buildMovieSection("🔥 Phim Hot", controller.hotList),
                  _buildMovieSection("⭐ Phim Xếp Hạng Cao", controller.topRatedList),
                ],
              );
            }),
            _buildFooterSection()
          ],
        ),
      ),
    );
  }

  Widget _buildMovieSection(String title, List<Movie> movies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {
                  final mainController = Get.find<MainController>();
                  mainController.changePage(1);
                },
                child: const Text(
                  'Xem thêm >',
                  style: TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            padding: const EdgeInsets.only(left: 15),
            itemBuilder: (context, index) {
              final movie = movies[index];
              return GestureDetector(
                onTap: () => Get.toNamed('/detail', arguments: movie),
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            movie.thumbUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[800],
                              child: const Icon(Icons.movie, color: Colors.grey),
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[900],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.redAccent,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        movie.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 13),
                          const SizedBox(width: 3),
                          Text(
                            movie.rating > 0
                                ? movie.rating.toStringAsFixed(1)
                                : 'N/A',
                            style: const TextStyle(
                                color: Colors.amber, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
Widget _buildFooterSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      color: const Color(0xFF0F0F14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "MOVIE APP - NHÓM 4",
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Đồ án môn học Lập trình di động\nTrường Đại học Công thương TP.HCM (HUIT)",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 15),
          const Divider(color: Colors.white10, thickness: 1),
          const SizedBox(height: 15),
          Text(
            "Phát triển bởi:",
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 15,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildFooterMemberName("Kỳ Anh"),
              _buildFooterMemberName("Nhân Hậu"),
              _buildFooterMemberName("Trọng Nhân"),
              _buildFooterMemberName("Việt Khoa"),
            ],
          ),
          const SizedBox(height: 25),
          Text(
            "© 2026 Nhóm 4 - HUIT. All Rights Reserved.",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterMemberName(String name) {
    return Text(
      name,
      style: TextStyle(
        color: Colors.grey[400],
        fontSize: 12,
      ),
    );
  }
// ── BANNER CAROUSEL ──
class _BannerCarousel extends StatefulWidget {
  final List<Movie> movies;
  const _BannerCarousel({required this.movies});

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (widget.movies.isEmpty) return;
      final next = (_currentPage + 1) % widget.movies.take(5).length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bannerMovies = widget.movies.take(5).toList();

    return Stack(
      children: [
        SizedBox(
          height: 260,
          child: PageView.builder(
            controller: _pageController,
            itemCount: bannerMovies.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final movie = bannerMovies[index];
              return GestureDetector(
                onTap: () => Get.toNamed('/detail', arguments: movie),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      movie.posterUrl.isNotEmpty
                          ? movie.posterUrl.replaceAll('w300', 'w780')
                          : movie.thumbUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.network(
                        movie.thumbUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.95),
                          ],
                          stops: const [0.3, 0.6, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 15,
                      right: 15,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                movie.rating > 0
                                    ? movie.rating.toStringAsFixed(1)
                                    : 'N/A',
                                style: const TextStyle(
                                    color: Colors.amber, fontSize: 13),
                              ),
                              const SizedBox(width: 12),
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
                                    children: [
                                      Icon(Icons.play_arrow,
                                          color: Colors.white, size: 16),
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
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Dot indicator
        Positioned(
          bottom: 8,
          right: 15,
          child: Row(
            children: List.generate(
              bannerMovies.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(left: 4),
                width: _currentPage == i ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentPage == i
                      ? Colors.redAccent
                      : Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}