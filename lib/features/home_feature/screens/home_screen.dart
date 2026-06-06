import 'package:flutter/material.dart';
import 'package:nhom4/features/home_feature/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'dart:async';

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "MOVIE-APP",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.cast, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () => Get.toNamed('/notifications'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Banner Trượt
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

            // 2. Danh sách Phim Mới
            Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: Colors.redAccent),
                );
              }
              if (controller.hasError.value) {
                return Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 40,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Không tải được phim',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: controller.fetchNewMovies,
                        child: Text(
                          'Thử lại',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  _buildMovieSection(
                    "🆕 Phim Mới Cập Nhật",
                    controller.newList,
                  ),
                  _buildMovieSection("🔥 Phim Hot", controller.hotList),
                  _buildMovieSection(
                    "⭐ Phim Xếp Hạng Cao",
                    controller.topRatedList,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieSection(String title, List<Movie> movies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header có nút Xem thêm
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              //*GestureDetector(
              //onTap: () {
              // Chuyển sang tab Khám phá
              //final mainController = Get.find<HomeScreen>();
              //mainController.changePage(1);
              //},
              //child: const Text(
              //'Xem thêm >',
              // style: TextStyle(color: Colors.redAccent, fontSize: 13),
              //),
              //),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length, // Lấy độ dài thật của danh sách từ API
            padding: EdgeInsets.only(left: 15),
            itemBuilder: (context, index) {
              final movie = movies[index];
              return GestureDetector(
                onTap: () {
                  Get.toNamed('/detail', arguments: movie);
                },
                child: Container(
                  width: 120,
                  margin: EdgeInsets.only(right: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ảnh phim
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            movie.thumbUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: Colors.grey[800],
                                  child: Icon(Icons.movie, color: Colors.grey),
                                ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[900],
                                child: Center(
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

                      SizedBox(height: 5),

                      // Tên phim
                      Text(
                        movie.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 3),

                      // Số sao
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 13),
                          SizedBox(width: 3),
                          Text(
                            movie.rating > 0
                                ? movie.rating.toStringAsFixed(1)
                                : 'N/A',
                            style: TextStyle(color: Colors.amber, fontSize: 11),
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
    // Tự động chuyển banner mỗi 4 giây
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (widget.movies.isEmpty) return;
      final next = (_currentPage + 1) % widget.movies.length;
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
    if (widget.movies.isEmpty) return const SizedBox.shrink();

    // Lấy 5 phim đầu làm banner
    final bannerMovies = widget.movies.take(5).toList();

    return Stack(
      children: [
        // ── PageView ảnh ──
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
                    // Ảnh backdrop
                    movie.posterUrl.isNotEmpty
                        ? Image.network(
                            // Dùng ảnh lớn hơn cho banner
                            movie.posterUrl.replaceAll('w300', 'w780'),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.network(
                              movie.thumbUrl,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.network(movie.thumbUrl, fit: BoxFit.cover),

                    // Gradient overlay
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

                    // Thông tin phim ở dưới
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
                              shadows: [
                                Shadow(color: Colors.black, blurRadius: 8),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                movie.rating > 0
                                    ? movie.rating.toStringAsFixed(1)
                                    : 'N/A',
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Nút xem ngay
                              GestureDetector(
                                onTap: () =>
                                    Get.toNamed('/detail', arguments: movie),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Xem ngay',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
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

        // ── Dot indicator ──
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
