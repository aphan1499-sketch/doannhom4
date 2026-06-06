import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:nhom4/features/home_feature/controllers/home_controller.dart';
import 'package:share_plus/share_plus.dart';

class PlayerScreen extends StatefulWidget {
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final Movie movie = Get.arguments['movie'];
  final int? initialEpisode = Get.arguments['episode'];
  final String _apiKey = '3061b48fa9e80eb147bd6f0deea56aeb';

  late WebViewController _webController;
  bool _isLoading = true;

  List<Map<String, dynamic>> _seasons = [];
  int _selectedSeason = 1;
  int _selectedEpisode = 1;
  int _totalEpisodes = 0;
  bool _isTvShow = false;
  bool _loadingEpisodes = true;

  // Phim liên quan
  List<Movie> _relatedMovies = [];
  bool _loadingRelated = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    _fetchMediaInfo();
    _fetchRelated();
  }

  void _shareMovie() {
    final String episodeInfo = _isTvShow
        ? '\n🎬 Đang xem: Mùa $_selectedSeason - Tập $_selectedEpisode'
        : '';

    final String rating = movie.rating > 0
        ? '⭐ ${movie.rating.toStringAsFixed(1)}/10'
        : '';

    final String text =
        '''
🎥 ${movie.name}
$rating$episodeInfo

Xem phim cùng mình trên Movie App - Nhóm 4!
''';

    Share.share(text.trim(), subject: movie.name);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  Future<void> _fetchMediaInfo() async {
    try {
      final tvRes = await http.get(
        Uri.parse(
          'https://api.themoviedb.org/3/tv/${movie.slug}?api_key=$_apiKey&language=vi-VN',
        ),
      );

      if (tvRes.statusCode == 200) {
        final data = json.decode(tvRes.body);
        final seasons = (data['seasons'] as List)
            .where((s) => s['season_number'] > 0)
            .toList();
        setState(() {
          _isTvShow = true;
          _seasons = List<Map<String, dynamic>>.from(seasons);
          _selectedSeason = 1;
          _selectedEpisode = initialEpisode ?? 1;
          _totalEpisodes = seasons.isNotEmpty
              ? seasons[0]['episode_count'] ?? 1
              : 1;
          _loadingEpisodes = false;
        });
      } else {
        setState(() {
          _isTvShow = false;
          _totalEpisodes = 1;
          _loadingEpisodes = false;
        });
      }
      _loadPlayer();
    } catch (e) {
      setState(() => _loadingEpisodes = false);
      _loadPlayer();
    }
  }

  Future<void> _fetchRelated() async {
    try {
      final res = await http.get(
        Uri.parse(
          'https://api.themoviedb.org/3/movie/${movie.slug}/similar?api_key=$_apiKey&language=vi-VN&page=1',
        ),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final list = (data['results'] as List)
            .take(10)
            .map((m) => Movie.fromJson(m))
            .toList();
        setState(() {
          _relatedMovies = list;
          _loadingRelated = false;
        });
      }
    } catch (e) {
      setState(() => _loadingRelated = false);
    }
  }

  Future<void> _fetchEpisodesForSeason(int season) async {
    try {
      final res = await http.get(
        Uri.parse(
          'https://api.themoviedb.org/3/tv/${movie.slug}/season/$season?api_key=$_apiKey',
        ),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          _totalEpisodes = (data['episodes'] as List).length;
          _selectedEpisode = 1;
        });
        _loadPlayer();
      }
    } catch (e) {}
  }

  void _loadPlayer() {
    final embedUrl = _isTvShow
        ? 'https://vidsrc.to/embed/tv/${movie.slug}/$_selectedSeason/$_selectedEpisode'
        : 'https://vidsrc.to/embed/movie/${movie.slug}';

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(embedUrl));

    setState(() => _webController = controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── VIDEO PLAYER ──
            SliverToBoxAdapter(child: _buildPlayer()),

            // ── THÔNG TIN PHIM ──
            SliverToBoxAdapter(child: _buildMovieInfo()),

            // ── CHỌN MÙA ──
            if (_isTvShow && _seasons.length > 1)
              SliverToBoxAdapter(child: _buildSeasonSelector()),

            // ── DANH SÁCH TẬP ──
            SliverToBoxAdapter(child: _buildEpisodeSection()),

            // ── PHIM LIÊN QUAN ──
            SliverToBoxAdapter(child: _buildRelatedSection()),

            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: _loadingEpisodes
              ? Container(
                  color: Colors.black,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.redAccent),
                  ),
                )
              : WebViewWidget(controller: _webController),
        ),
        if (_isLoading)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black87,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.redAccent),
              ),
            ),
          ),
        // Nút back
        Positioned(
          top: 10,
          left: 10,
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMovieInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tên phim + tập đang xem
          Text(
            movie.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_isTvShow) ...[
            const SizedBox(height: 4),
            Text(
              'Mùa $_selectedSeason • Tập $_selectedEpisode',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ],
          const SizedBox(height: 10),

          // Rating + nút chia sẻ
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                movie.rating > 0 ? movie.rating.toStringAsFixed(1) : 'N/A',
                style: const TextStyle(color: Colors.amber, fontSize: 14),
              ),
              const Spacer(),
              _actionButton(Icons.thumb_up_outlined, 'Thích'),
              const SizedBox(width: 20),
              _actionButton(Icons.add, 'Lưu'),
              const SizedBox(width: 20),
              _actionButton(
                Icons.share_outlined,
                'Chia sẻ',
                onTap: _shareMovie, // GẮN VÀO ĐÂY
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: Color(0xFF222222)),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSeasonSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 5, 15, 10),
          child: Text(
            'Chọn mùa',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: _seasons.length,
            itemBuilder: (context, index) {
              final seasonNum = _seasons[index]['season_number'];
              final isSelected = seasonNum == _selectedSeason;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedSeason = seasonNum);
                  _fetchEpisodesForSeason(seasonNum);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.redAccent
                        : const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.redAccent
                          : const Color(0xFF333333),
                    ),
                  ),
                  child: Text(
                    'Mùa $seasonNum',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[400],
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildEpisodeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isTvShow)
            Text(
              'Danh sách tập  •  $_totalEpisodes tập',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 12),

          if (!_isTvShow)
            // Phim lẻ → FULL chip
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.redAccent, Color(0xFFFF6B6B)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.play_arrow, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'FULL',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            // Phim bộ → lưới tập
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.4,
              ),
              itemCount: _totalEpisodes,
              itemBuilder: (context, index) {
                final ep = index + 1;
                final isSelected = ep == _selectedEpisode;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedEpisode = ep);
                    _loadPlayer();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.redAccent
                          : const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected
                            ? Colors.redAccent
                            : const Color(0xFF2E2E2E),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$ep',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[400],
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: 25),
          const Divider(color: Color(0xFF1E1E1E)),
        ],
      ),
    );
  }

  Widget _buildRelatedSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Có thể bạn cũng thích',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          if (_loadingRelated)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: Colors.redAccent),
              ),
            )
          else if (_relatedMovies.isEmpty)
            Center(
              child: Text(
                'Không có phim liên quan',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _relatedMovies.length,
              itemBuilder: (context, index) {
                final m = _relatedMovies[index];
                return GestureDetector(
                  onTap: () {
                    // Chuyển sang phim khác
                    Get.off(
                      () => PlayerScreen(),
                      arguments: {'movie': m, 'episode': 1},
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        // Thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: m.thumbUrl.isNotEmpty
                              ? Image.network(
                                  m.thumbUrl,
                                  width: 120,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _placeholderThumb(),
                                )
                              : _placeholderThumb(),
                        ),
                        const SizedBox(width: 12),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    m.rating > 0
                                        ? m.rating.toStringAsFixed(1)
                                        : 'N/A',
                                    style: const TextStyle(
                                      color: Colors.amber,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons.play_circle_outline,
                          color: Colors.grey,
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _placeholderThumb() {
    return Container(
      width: 120,
      height: 70,
      color: const Color(0xFF1E1E1E),
      child: const Icon(Icons.movie, color: Colors.grey, size: 30),
    );
  }
}
