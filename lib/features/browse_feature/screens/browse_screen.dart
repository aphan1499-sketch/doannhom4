import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/search_controller.dart';
import 'search_screen.dart' as search_ui;

class BrowseScreen extends StatelessWidget {
   const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(BrowseController(), permanent: false);
    return search_ui.BrowseScreen();
  }
}
