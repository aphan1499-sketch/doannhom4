import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:dio/io.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class BrowseController extends GetxController {
  final GetStorage _storage = GetStorage();
  late final dio.Dio _dio =
      dio.Dio(
          dio.BaseOptions(
            baseUrl: 'https://api.themoviedb.org/3',
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
            queryParameters: <String, dynamic>{
              'api_key': '3061b48fa9e80eb147bd6f0deea56aeb',
              'language': 'vi-VN',
            },
          ),
        )
        ..httpClientAdapter = IOHttpClientAdapter(
          createHttpClient: () {
            final HttpClient client = HttpClient();
            client.badCertificateCallback =
                (X509Certificate cert, String host, int port) => true;
            return client;
          },
        );

  final RxString searchQuery = ''.obs;
  final RxnInt selectedGenreId = RxnInt();
  final RxnInt selectedYear = RxnInt();
  final RxList<dynamic> movieList = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxBool isVip = false.obs;

  final Map<String, int> genreMap = <String, int>{
    'Action': 28,
    'Comedy': 35,
    'Drama': 18,
    'Horror': 27,
    'Romance': 10749,
    'Sci-Fi': 878,
    'Animation': 16,
    'Thriller': 53,
    'Family': 10751,
    'Documentary': 99,
  };

  final List<int> yearOptions = <int>[2024, 2023, 2022, 2021, 2020];

  bool _isFetching = false;

  @override
  void onInit() {
    super.onInit();
    isVip.value = _storage.read<bool>('isVip') ?? false;
    debounce(
      searchQuery,
      (_) => fetchMovies(),
      time: const Duration(milliseconds: 500),
    );
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    if (_isFetching) {
      return;
    }

    final String query = searchQuery.value.trim();

    _isFetching = true;
    isLoading.value = true;
    hasError.value = false;

    try {
      if (query.isNotEmpty) {
        await fetchSearchMovies(query);
        return;
      }

      if (selectedGenreId.value != null || selectedYear.value != null) {
        await fetchFilteredMovies();
        return;
      }

      await fetchTrendingMovies();
    } catch (_) {
      hasError.value = true;
      movieList.clear();
    } finally {
      _isFetching = false;
      isLoading.value = false;
    }
  }

  Future<void> fetchTrendingMovies() async {
    await _runRequest(
      () => _dio.get(
        '/trending/movie/day',
        queryParameters: <String, dynamic>{'page': 1},
      ),
    );
  }

  Future<void> fetchSearchMovies(String query) async {
    await _runRequest(
      () => _dio.get(
        '/search/movie',
        queryParameters: <String, dynamic>{'query': query, 'page': 1},
      ),
    );
  }

  Future<void> fetchFilteredMovies() async {
    await _runRequest(
      () => _dio.get(
        '/discover/movie',
        queryParameters: <String, dynamic>{
          'with_genres': selectedGenreId.value,
          'primary_release_year': selectedYear.value,
          'sort_by': 'popularity.desc',
          'page': 1,
        },
      ),
    );
  }

  Future<void> _runRequest(
    Future<dio.Response<dynamic>> Function() request,
  ) async {
    try {
      final dio.Response<dynamic> response = await request();
      final List<dynamic> results =
          (response.data['results'] as List<dynamic>? ?? <dynamic>[]);
      movieList.assignAll(results);
      if (results.isEmpty) {
        hasError.value = false;
      }
    } on dio.DioException catch (_) {
      hasError.value = true;
      movieList.clear();
    }
  }

  void selectGenre(String genre) {
    selectedGenreId.value = genreMap[genre];
    fetchMovies();
  }

  void selectYear(int year) {
    selectedYear.value = year;
    fetchMovies();
  }

  Future<void> refreshMovies() => fetchMovies();

  void setVipStatus(bool status) {
    isVip.value = status;
    _storage.write('isVip', status);
  }

  void clearFilters() {
    selectedGenreId.value = null;
    selectedYear.value = null;
    searchQuery.value = '';
    fetchMovies();
  }
}
