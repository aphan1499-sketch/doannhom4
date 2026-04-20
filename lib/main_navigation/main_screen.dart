import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nhom4/features/home_feature/screens/home_screen.dart';
import 'main_controller.dart';
// Import 4 màn hình chính của 4 bạn
// import '../features/home_feature/screens/home_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  final MainController controller = Get.put(MainController());

  // Danh sách 4 màn hình đại diện cho 4 Tab
  final List<Widget> screens = [
    HomeScreen(),  
    Center(child: Text("Browse - Thành viên 2")),
    Center(child: Text("Library - Thành viên 3")),
    Center(child: Text("Profile - Thành viên 4")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => screens[controller.currentIndex.value]),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.currentIndex.value,
        onTap: controller.changePage,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Khám phá"),
          BottomNavigationBarItem(icon: Icon(Icons.video_library), label: "Thư viện"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Cá nhân"),
        ],
      )),
    );
  }
}