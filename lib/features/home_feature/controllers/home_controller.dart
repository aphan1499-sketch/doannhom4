import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:nhom4/data/local_storage.dart';

class HomeController extends GetxController {
  var newList = <Movie>[].obs; // Danh sách phim mới
  var isLoading = true.obs;

  @override
  void onInit() {
    fetchNewMovies();
    super.onInit();
  }

  void fetchNewMovies() async {
    try {
      isLoading(true);
      // Gọi API phim mới cập nhật từ OPhim
      var response = await http.get(Uri.parse('https://ophim1.com/danh-sach/phim-moi-cap-nhat?page=1'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var list = data['items'] as List;
        newList.value = list.map((m) => Movie.fromJson(m)).toList();
      }
    } finally {
      isLoading(false);
    }
  }
}