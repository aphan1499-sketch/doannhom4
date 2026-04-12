import 'package:get/get.dart';

class MainController extends GetxController {
  var currentIndex = 0.obs; // Quan sát chỉ số tab hiện tại

  void changePage(int index) {
    currentIndex.value = index;
  }
}