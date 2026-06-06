import 'package:flutter/material.dart';
import 'package:get/get.dart';
<<<<<<< HEAD
import 'package:get_storage/get_storage.dart';

import 'main_navigation/main_controller.dart';
import 'main_navigation/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(MainController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Movie App',
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
      home: const MainScreen(),
    );
  }
}
=======
import 'core/routes.dart';
import 'main_navigation/main_screen.dart';

void main() {
  runApp(MovieApp());
}

class MovieApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Movie App - Nhóm 4',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: MainNavigationScreen(),
      getPages: AppRoutes.routes,
    );
  }
}
>>>>>>> c7c2acfbbfc0e9bba6569114d267fa8a20b87f5d
