import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/routes.dart';
import 'main_navigation/main_screen.dart';
import 'package:nhom4/core/notification_service.dart';
import 'package:get_storage/get_storage.dart';
import 'main_navigation/main_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await GetStorage.init();
  Get.put(MainController(), permanent: true);
  runApp(MovieApp());
}
class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Movie App - Nhóm 4',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0B0F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE50914),
          secondary: Color(0xFF1F1F29),
          surface: Color(0xFF121318),
        ),
      ),
      home: MainNavigationScreen(),
      getPages: AppRoutes.routes,
    );
  }
}    