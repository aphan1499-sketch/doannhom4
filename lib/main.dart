import 'package:flutter/material.dart';
import 'package:get/get.dart';
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