import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/routes.dart';
import 'main_navigation/main_screen.dart';
import 'package:nhom4/core/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await NotificationService.init();          
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