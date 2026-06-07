import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'main_navigation/main_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/profile_feature/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables securely from .env
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Khởi tạo AuthController ngay khi app vừa chạy
  Get.put(AuthController());

  runApp(const MovieApp());
}

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Gọi AuthController ra để lấy trạng thái DarkMode hiện tại
    final AuthController authController = Get.find<AuthController>();

    return Obx(
      () => GetMaterialApp(
        title: 'App Phim HUIT',
        debugShowCheckedModeBanner: false,

        // 1. Cấu hình giao diện Sáng
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
        ),

        // 2. Cấu hình giao diện Tối
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
        ),

        // 3. Quyết định xem ban đầu dùng mode nào dựa vào biến isDarkMode trong Controller
        themeMode: authController.isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,

        home: MainNavigationScreen(),
      ),
    );
  }
}
