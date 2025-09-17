// Custom Sliding Navigation App Bar
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomSlidingAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  final String title;
  final List<String> navItems;
  final int currentIndex;
  final Function(int) onNavChanged;
  final List<Widget> actions;

  const CustomSlidingAppBar({
    super.key,
    required this.title,
    required this.navItems,
    required this.currentIndex,
    required this.onNavChanged,
    this.actions = const [],
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  State<CustomSlidingAppBar> createState() => _CustomSlidingAppBarState();
}

class _CustomSlidingAppBarState extends State<CustomSlidingAppBar>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF000000),
        border: Border(
          bottom: BorderSide(color: Color(0xFF2C2C2E), width: 0.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Main App Bar Content
            Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Title with Icon
                  Row(
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
