import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FloatingQuranAppBar extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onBack;
  final VoidCallback onNavigator;
  final VoidCallback onSettings;
  final VoidCallback onSearch;
  final Color backgroundColor;
  final Color iconColor;

  const FloatingQuranAppBar({
    Key? key,
    required this.isVisible,
    required this.onBack,
    required this.onNavigator,
    required this.onSettings,
    required this.onSearch,
    required this.backgroundColor,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutQuart,
      top: isVisible ? 0 : -100, // Slide up/down
      left: 0,
      right: 0,
      height: 90.h,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.95),
          boxShadow: [
            if (isVisible)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
          ],
        ),
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
        ), // account for safe area
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onBack,
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  size: 24.sp,
                  color: iconColor,
                ),
              ),
              Row(
                spacing: 8,
                children: [
                  IconButton(
                    onPressed: onSearch,
                    icon: Icon(
                      Icons.search_rounded,
                      size: 24.sp,
                      color: iconColor,
                    ),
                  ),
                  IconButton(
                    onPressed: onNavigator,
                    icon: Icon(
                      Icons.menu_book_rounded,
                      size: 24.sp,
                      color: iconColor,
                    ),
                  ),
                  IconButton(
                    onPressed: onSettings,
                    icon: Icon(
                      Icons.settings,
                      size: 24.sp,
                      color: iconColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
