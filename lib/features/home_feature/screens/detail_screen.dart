import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:convert';
import 'package:nhom4/features/home_feature/controllers/home_controller.dart';

class DetailScreen extends StatefulWidget {
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final Movie movie = Get.arguments;
  final String _apiKey = '3061b48fa9e80eb147bd6f0deea56aeb';

  // Trailer
  String? _trailerKey;
  YoutubePlayerController? _ytController;
  bool _loadingTrailer = true;

  // Chi tiết phim
  Map<String, dynamic>? _detail;
  bool _loadingDetail = true;

  // Bình luận (giả lập vì TMDB không cho post)
  final TextEditingController _commentController = TextEditingController();
  final RxList<Map<String, String>> _comments = <Map<String, String>>[].obs;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
    _fetchTrailer();
  }

  Future<void> _fetchDetail() async {
    try {
      final res = await http.get(
        Uri.parse(
          'https://api.themoviedb.org/3/movie/${movie.slug}?api_key=$_apiKey&language=vi-VN',
        ),
      );
      if (res.statusCode == 200) {
        setState(() {
          _detail = json.decode(res.body);
          _loadingDetail = false;
        });
      }
    } catch (e) {
      setState(() => _loadingDetail = false);
    }
  }

  Future<void> _fetchTrailer() async {
    try {
      final res = await http.get(
        Uri.parse(
          'https://api.themoviedb.org/3/movie/${movie.slug}/videos?api_key=$_apiKey&language=en-US',
        ),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final videos = data['results'] as List;
        // Tìm trailer YouTube
        final trailer = videos.firstWhere(
          (v) => v['site'] == 'YouTube' && v['type'] == 'Trailer',
          orElse: () => videos.isNotEmpty ? videos.first : null,
        );
        if (trailer != null) {
          final key = trailer['key'];
          setState(() {
            _trailerKey = key;
            _ytController = YoutubePlayerController(
              initialVideoId: key,
              flags: const YoutubePlayerFlags(autoPlay: false),
            );
          });
        }
      }
    } catch (e) {
      print('Trailer error: $e');
    } finally {
      setState(() => _loadingTrailer = false);
    }
  }

  @override
  void dispose() {
    _ytController?.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller:
            _ytController ??
            YoutubePlayerController(
              initialVideoId: '',
              flags: const YoutubePlayerFlags(autoPlay: false),
            ),
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── TRAILER hoặc BACKDROP ──
                _buildTrailerOrBackdrop(player),

                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── TÊN PHIM ──
                      Text(
                        movie.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ── RATING & THÔNG TIN ──
                      _buildInfoRow(),
                      const SizedBox(height: 15),

                      // ── NÚT XEM PHIM ──
                      _buildWatchButton(),
                      const SizedBox(height: 20),

                      // ── MÔ TẢ ──
                      _buildOverview(),
                      const SizedBox(height: 25),

                      // ── BÌNH LUẬN ──
                      _buildCommentSection(),
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

  Widget _buildTrailerOrBackdrop(Widget player) {
    return Stack(
      children: [
        if (_trailerKey != null)
          player
        else
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              image: movie.posterUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(movie.posterUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _loadingTrailer
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.redAccent),
                  )
                : const Center(
                    child: Icon(Icons.movie, color: Colors.grey, size: 60),
                  ),
          ),

        // Nút back
        Positioned(
          top: 40,
          left: 10,
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow() {
    final genres =
        (_detail?['genres'] as List?)
            ?.map((g) => g['name'].toString())
            .join(', ') ??
        '';
    final runtime = _detail?['runtime'];
    final releaseDate = _detail?['release_date'] ?? '';
    final year = releaseDate.length >= 4 ? releaseDate.substring(0, 4) : '';

    return Wrap(
      spacing: 10,
      runSpacing: 6,
      children: [
        // Rating
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.amber),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 14),
              const SizedBox(width: 4),
              Text(
                movie.rating.toStringAsFixed(1),
                style: const TextStyle(color: Colors.amber, fontSize: 13),
              ),
            ],
          ),
        ),

        if (year.isNotEmpty) _infoChip(Icons.calendar_today, year),

        if (runtime != null && runtime > 0)
          _infoChip(Icons.access_time, '${runtime} phút'),

        if (genres.isNotEmpty) _infoChip(Icons.category, genres),
      ],
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.grey[400], size: 13),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: Colors.grey[300], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildWatchButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: navigate sang màn hình chiếu phim
          Get.toNamed('/player', arguments: {'movie': movie, 'episode': 1});
        },
        icon: const Icon(Icons.play_circle_filled, size: 22),
        label: const Text('XEM PHIM', style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildOverview() {
    final overview = _detail?['overview'] ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nội dung',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          overview.isNotEmpty ? overview : 'Chưa có mô tả.',
          style: TextStyle(color: Colors.grey[400], fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bình luận',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Ô nhập bình luận
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Viết bình luận...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                final text = _commentController.text.trim();
                if (text.isNotEmpty) {
                  _comments.add({'user': 'Bạn', 'text': text});
                  _commentController.clear();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        // Danh sách bình luận
        Obx(
          () => _comments.isEmpty
              ? Center(
                  child: Text(
                    'Chưa có bình luận nào.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : Column(
                  children: _comments.map((c) => _buildCommentItem(c)).toList(),
                ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildCommentItem(Map<String, String> comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.redAccent,
            child: Text(
              comment['user']![0],
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment['user']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comment['text']!,
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
