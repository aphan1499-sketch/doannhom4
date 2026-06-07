import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'main_controller.dart';
// Import màn hình Profile của bạn (Thành viên 2)
import '../features/profile_feature/screens/profile_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  final MainController controller = Get.put(MainController());

  // Cập nhật danh sách màn hình, thay thế Tab 4 bằng ProfileScreen của bạn
  late final List<Widget> screens = [
    const Center(child: Text("Home - Thành viên 1")),  
    const Center(child: Text("Browse - Thành viên 3")), // (Sửa lại tên TV cho đúng tài liệu)
    const Center(child: Text("Library - Thành viên 4")), // (Sửa lại tên TV cho đúng tài liệu)
    ProfileScreen(), // <-- Đưa giao diện của bạn vào vị trí cuối cùng (Tab Cá nhân)
  ];

  MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => screens[controller.currentIndex.value]),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.currentIndex.value,
        onTap: controller.changePage,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.redAccent, // Nhóm trưởng dùng màu đỏ
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Khám phá"),
          BottomNavigationBarItem(icon: Icon(Icons.video_library), label: "Thư viện"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Cá nhân"),
        ],
      )),
    );
  }
}