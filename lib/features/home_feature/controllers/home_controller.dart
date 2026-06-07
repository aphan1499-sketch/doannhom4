import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:nhom4/features/home_feature/screens/notification_screen.dart';

class Movie {
  final String name;
  final String slug;
  final String thumbUrl;
  final String posterUrl;
  final double rating;

  Movie({
    required this.name,
    required this.slug,
    required this.thumbUrl,
    required this.posterUrl,
    required this.rating,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    const String imgBase = 'https://image.tmdb.org/t/p/w300';
    final poster = json['poster_path'] ?? '';
    final backdrop = json['backdrop_path'] ?? '';

    return Movie(
      name: json['title'] ?? json['name'] ?? '',
      slug: json['id'].toString(),
      thumbUrl: poster.isNotEmpty ? '$imgBase$poster' : '',
      posterUrl: backdrop.isNotEmpty ? '$imgBase$backdrop' : '',
      rating: (json['vote_average'] ?? 0.0).toDouble(),
    );
  }
}

class HomeController extends GetxController {
  // *** THAY BẰNG API KEY CỦA BẠN ***
  final String _apiKey = '3061b48fa9e80eb147bd6f0deea56aeb';
  final String _base = 'https://api.themoviedb.org/3';

  var newList = <Movie>[].obs;
  var hotList = <Movie>[].obs;
  var topRatedList = <Movie>[].obs;
  var isLoading = true.obs;
  var hasError = false.obs;

  @override
  void onInit() {
    fetchAllMovies();
    super.onInit();
  }

  void fetchAllMovies() async {
    try {
      isLoading(true);
      hasError(false);

      await Future.wait([
        _fetchList(
          '$_base/movie/now_playing?api_key=$_apiKey&language=vi-VN&page=1',
          newList,
        ),
        _fetchList(
          '$_base/trending/movie/week?api_key=$_apiKey&language=vi-VN',
          hotList,
        ),
        _fetchList(
          '$_base/movie/top_rated?api_key=$_apiKey&language=vi-VN&page=1',
          topRatedList,
        ),
      ]);
    } catch (e) {
      print('=== ERROR: $e');
      hasError(true);
    } finally {
      isLoading(false);
    }
  }

  Future<void> _fetchList(String url, RxList<Movie> targetList) async {
  try {
    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final list = (data['results'] as List)
          .map((m) => Movie.fromJson(m))
          .toList();

      // Lưu phim mới vào lịch sử thông báo (chỉ cho newList)
      if (targetList == newList) {
        for (final movie in list) {
          NotificationHistory.add(movie); // THÊM
        }
      }

      targetList.value = list;
    }
  } catch (e) {
    print('>>> Exception: $e');
  }
}

  // Giữ lại để nút "Thử lại" hoạt động
  void fetchNewMovies() => fetchAllMovies();
}