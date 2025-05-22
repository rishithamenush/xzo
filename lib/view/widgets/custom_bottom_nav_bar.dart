import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:turathi/view/view_layer.dart';

import '../screens/progress_screen.dart';
import '../screens/schedule_screen.dart';


class NavigationDestination {
  final IconData icon;
  final String label;
  final int index;

  NavigationDestination({
    required this.index,
    required this.icon,
    required this.label,
  });
}

class NavigationBar extends StatelessWidget {
  final Color backgroundColor;
  final double elevation;
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final List<NavigationDestination> destinations;
  final double iconSize;

  const NavigationBar({
    super.key,
    required this.backgroundColor,
    required this.elevation,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: destinations.map((destination) {
          final bool isSelected = selectedIndex == destination.index;
          final Color selectedColor = Color(0xFF7A0019); // Red
          final Color unselectedColor = Color(0xFFBDBDBD); // Gray
          return Expanded(
            child: InkWell(
              onTap: () => onDestinationSelected(destination.index),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      destination.icon,
                      size: iconSize,
                      color: isSelected ? selectedColor : unselectedColor,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      destination.label,
                      style: TextStyle(
                        color: isSelected ? selectedColor : unselectedColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class CustomeBottomNavBar extends StatelessWidget {
  const CustomeBottomNavBar({Key? key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Obx(
          () => NavigationBar(
            backgroundColor: Colors.black,
            elevation: 0,
            selectedIndex: controller.selectedIndex.value,
            onDestinationSelected: (index) {
              controller.selectedIndex.value = index;
            },
            destinations: [
              NavigationDestination(
                icon: Icons.home_outlined,
                label: 'Home',
                index: 0,
              ),
              NavigationDestination(
                icon: Icons.bar_chart_outlined,
                label: 'Progress',
                index: 1,
              ),
              NavigationDestination(
                icon: Icons.calendar_today_outlined,
                label: 'Schedule',
                index: 2,
              ),
              NavigationDestination(
                icon: Icons.storefront_outlined,
                label: 'Shop',
                index: 3,
              ),
              NavigationDestination(
                icon: Icons.person_outline,
                label: 'Profile',
                index: 4,
              ),
            ],
            iconSize: LayoutManager.widthNHeight0(context, 1) * 0.064,
          ),
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
  final screens = [
    HomeScreen(), // Home
    ProgressScreen(), // Progress (create this screen if not exists)
    ScheduleScreen(), // Schedule (create this screen if not exists)
    ShopScreen(), // Shop (create this screen if not exists)
    ProfileScreen(), // Profile
  ];
}
