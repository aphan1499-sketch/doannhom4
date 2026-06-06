import 'package:flutter/material.dart';
import 'package:get/get.dart';
<<<<<<< HEAD

import 'main_controller.dart';

class MainScreen extends GetView<MainController> {
  const MainScreen({super.key});
=======
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
>>>>>>> c7c2acfbbfc0e9bba6569114d267fa8a20b87f5d

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: const Color(0xFF0B0B0F),
      body: Obx(
        () => IndexedStack(
          index: controller.selectedIndex.value,
          children: controller.pages,
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF121318),
          selectedItemColor: const Color(0xFFE50914),
          unselectedItemColor: Colors.white54,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          items: controller.navigationItems,
        ),
      ),
    );
  }
}
=======
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
>>>>>>> c7c2acfbbfc0e9bba6569114d267fa8a20b87f5d
