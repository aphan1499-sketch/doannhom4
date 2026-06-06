import 'package:get/get.dart';
// Import tất cả screens của các thành viên ở đây
// import 'package:movie_app/features/home_feature/screens/home_screen.dart'; 

class AppRoutes {
  static const String initial = '/';
  static const String movieDetail = '/detail';
  static const String login = '/login';
  static const String search = '/search';

  static List<GetPage> routes = [
    // Nhóm trưởng sẽ thêm các GetPage tương ứng với screen của mỗi bạn vào đây
    /* GetPage(name: initial, page: () => MainNavigationScreen()), */
  ];
}