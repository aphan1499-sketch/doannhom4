import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/search_controller.dart';
import 'vip_screen.dart';
import 'package:nhom4/features/home_feature/controllers/home_controller.dart';

class BrowseScreen extends GetView<BrowseController> {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Obx(() {
                final bool isTrending =
                    controller.searchQuery.value.trim().isEmpty &&
                    controller.selectedGenreId.value == null &&
                    controller.selectedYear.value == null;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      isTrending ? 'Gợi ý cho bạn' : 'Kết quả tìm kiếm',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isTrending
                          ? 'Danh sách phim nổi bật hôm nay từ TMDB.'
                          : 'Kết quả từ từ khóa và bộ lọc bạn chọn.',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 8),
              Obx(
                () => Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => Get.to(const VipScreen()),
                    icon: Icon(controller.isVip.value
                        ? Icons.diamond_rounded
                        : Icons.diamond_outlined),
                    label: Text(controller.isVip.value
                        ? 'Thành viên VIP ⭐'
                        : 'Nâng cấp VIP'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFBBF24),
                      foregroundColor: const Color(0xFF111827),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF171A22),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Tìm phim theo tên...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF171A22),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    suffixIcon: Obx(
                      () => controller.searchQuery.value.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                controller.searchQuery.value = '';
                                controller.fetchMovies();
                              },
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.white54,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  onChanged: (String value) =>
                      controller.searchQuery.value = value,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.genreMap.keys.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (BuildContext context, int index) {
                    final String genre = controller.genreMap.keys.elementAt(
                      index,
                    );
                    final bool isSelected =
                        controller.selectedGenreId.value ==
                        controller.genreMap[genre];

                    return GestureDetector(
                      onTap: () => controller.selectGenre(genre),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.white12,
                          ),
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: <Color>[
                                    Color(0xFFFBBF24),
                                    Color(0xFFF59E0B),
                                    Color(0xFFB45309),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isSelected ? null : const Color(0xFF171A22),
                          boxShadow: isSelected
                              ? const [
                                  BoxShadow(
                                    color: Color(0x55FBBF24),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                    offset: Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          genre,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white70,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.yearOptions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (BuildContext context, int index) {
                    final int year = controller.yearOptions[index];
                    final bool isSelected =
                        controller.selectedYear.value == year;

                    return ChoiceChip(
                      label: Text('$year'),
                      selected: isSelected,
                      selectedColor: const Color(0xFFEAB308),
                      backgroundColor: const Color(0xFF171A22),
                      side: const BorderSide(color: Colors.white12),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                      onSelected: (_) => controller.selectYear(year),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: controller.clearFilters,
                  icon: const Icon(Icons.filter_alt_off, color: Colors.white70),
                  label: const Text(
                    'Xóa lọc',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return RefreshIndicator(
                      onRefresh: controller.refreshMovies,
                      color: Colors.amber,
                      backgroundColor: const Color(0xFF171A22),
                      child: GridView.builder(
                        padding: const EdgeInsets.only(top: 4, bottom: 12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.68,
                            ),
                        itemCount: 6,
                        itemBuilder: (context, index) =>
                            const PulsingSkeletonCard(),
                      ),
                    );
                  }

                  if (controller.hasError.value) {
                    return const Center(
                      child: Text(
                        'Không thể tải dữ liệu TMDB.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  if (controller.movieList.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: <Color>[
                                    Color(0xFFFFF7C2),
                                    Color(0xFFFBBF24),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: const <BoxShadow>[
                                  BoxShadow(
                                    color: Color(0x44FBBF24),
                                    blurRadius: 18,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.search_off_rounded,
                                color: Color(0xFF111827),
                                size: 38,
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'Không tìm thấy phim',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Thử từ khóa khác hoặc bỏ bộ lọc để xem thêm kết quả.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: controller.clearFilters,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFBBF24),
                                foregroundColor: const Color(0xFF111827),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                              ),
                              icon: const Icon(Icons.filter_alt_off),
                              label: const Text('Bỏ bộ lọc'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: controller.refreshMovies,
                    color: Colors.amber,
                    backgroundColor: const Color(0xFF171A22),
                    child: GridView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.68,
                          ),
                      itemCount: controller.movieList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final dynamic movie = controller.movieList[index];

                        return _MovieCard(movie: movie, index: index);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MovieCard extends StatefulWidget {
  const _MovieCard({required this.movie, required this.index});

  final dynamic movie;
  final int index;

  @override
  State<_MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<_MovieCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final String title = widget.movie['title']?.toString() ?? 'Không rõ';
    final String year = (widget.movie['release_date'] ?? '')
        .toString()
        .split('-')
        .first;
    final String posterPath = widget.movie['poster_path']?.toString() ?? '';
    final String posterUrl = posterPath.isEmpty
        ? 'https://via.placeholder.com/500x750?text=No+Image'
        : 'https://image.tmdb.org/t/p/w500$posterPath';

    return GestureDetector(
      onTap: () {
        final BrowseController controller = Get.find<BrowseController>();
        if (widget.index.isEven && !controller.isVip.value) {
          showDialog<void>(
            context: context,
            builder: (BuildContext dialogContext) => AlertDialog(
              backgroundColor: const Color(0xFF111827),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              titlePadding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              contentPadding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              title: const Text(
                'Nội dung VIP',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: const Text(
                'Vui lòng nâng cấp VIP để thưởng thức bộ phim này.',
                style: TextStyle(color: Colors.white70),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Đóng'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Get.to(const VipScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFBBF24),
                    foregroundColor: const Color(0xFF111827),
                  ),
                  child: const Text('Nâng cấp ngay'),
                ),
              ],
            ),
          );
          return;
        }

        // Dùng Movie.fromJson cho gọn, đúng với class Movie đã định nghĩa
        final Movie movieObj = Movie.fromJson(
          Map<String, dynamic>.from(widget.movie as Map),
        );
        Get.toNamed('/detail', arguments: movieObj);
      },
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        scale: _isPressed ? 0.95 : 1.0,
        child: Card(
          elevation: 8,
          color: const Color(0xFF151821),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: <Widget>[
                Image.network(
                  posterUrl,
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF1F2430),
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[Color(0x00000000), Color(0xCC000000)],
                      ),
                    ),
                  ),
                ),
                if (widget.index.isEven)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color(0xFFFFE08A),
                          width: 1.1,
                        ),
                        gradient: const LinearGradient(
                          colors: <Color>[
                            Color(0xFFFFF7C2),
                            Color(0xFFFBBF24),
                            Color(0xFFF59E0B),
                            Color(0xFFB45309),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x66FBBF24),
                            blurRadius: 12,
                            spreadRadius: 1.2,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'VIP',
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        year.isEmpty ? 'N/A' : year,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PulsingSkeletonCard extends StatefulWidget {
  const PulsingSkeletonCard({super.key});

  @override
  State<PulsingSkeletonCard> createState() => _PulsingSkeletonCardState();
}

class _PulsingSkeletonCardState extends State<PulsingSkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double opacity = 0.3 + (0.5 * _controller.value);

        return Card(
          elevation: 6,
          color: const Color(0xFF151821),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Opacity(
            opacity: opacity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 170,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A3142),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 12,
                        width: 90,
                        color: const Color(0xFF2A3142),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 10,
                        width: 60,
                        color: const Color(0xFF2A3142),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}