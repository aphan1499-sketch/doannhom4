import 'package:get/get.dart';
import 'package:nhom4/features/home_feature/screens/detail_screen.dart';
import 'package:nhom4/features/home_feature/screens/notification_screen.dart';
import 'package:nhom4/features/home_feature/screens/player_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String movieDetail = '/detail';
  static const String notifications = '/notifications';
  static const String login = '/login';
  static const String search = '/search';

  static List<GetPage> routes = [
    GetPage(name: movieDetail, page: () => DetailScreen()),
    GetPage(name: notifications, page: () => NotificationScreen()),
    GetPage(name: '/player', page: () => PlayerScreen()),
  ];
}