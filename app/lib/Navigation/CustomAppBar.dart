// Custom Sliding Navigation App Bar
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomSlidingAppBar extends StatefulWidget implements PreferredSizeWidget {
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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 60);

  @override
  State<CustomSlidingAppBar> createState() => _CustomSlidingAppBarState();
}

class _CustomSlidingAppBarState extends State<CustomSlidingAppBar> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          // Main App Bar Content
          Container(
            height: kToolbarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Row(
                  children: widget.actions,
                ),
              ],
            ),
          ),

          // Sliding Navigation
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  // Navigation Items
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(widget.navItems.length, (index) {
                      final isSelected = index == widget.currentIndex;
                      return GestureDetector(
                        onTap: () => widget.onNavChanged(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.navItems[index],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  // Sliding Indicator
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: (MediaQuery.of(context).size.width /
                        widget.navItems.length) *
                        widget.currentIndex + 24,
                    bottom: 0,
                    child: Container(
                      width: (MediaQuery.of(context).size.width - 48) /
                          widget.navItems.length,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}