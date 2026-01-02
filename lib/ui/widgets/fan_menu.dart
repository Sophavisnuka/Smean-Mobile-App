import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:smean_mobile_app/constants/app_colors.dart';

class FanMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  FanMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
}

class FanMenu extends StatefulWidget {
  final List<FanMenuItem> items;
  final bool isOpen;
  final VoidCallback onToggle;

  const FanMenu({
    super.key,
    required this.items,
    required this.isOpen,
    required this.onToggle,
  });

  @override
  State<FanMenu> createState() => _FanMenuState();
}

class _FanMenuState extends State<FanMenu> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.625, // 225 degrees (0.625 turns = 225/360)
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FanMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen && !oldWidget.isOpen) {
      _controller.forward();
    } else if (!widget.isOpen && oldWidget.isOpen) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 280,
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          // Fan menu items - Positioned vertically above FAB
          ...List.generate(widget.items.length, (index) {
            // Calculate vertical position for each item
            // Space items 80 pixels apart vertically, starting from 90px above FAB
            final double baseDistance = 90.0;
            final double itemSpacing = 80.0;
            final double yOffset = baseDistance + (index * itemSpacing);

            return AnimatedBuilder(
              animation: _expandAnimation,
              builder: (context, child) {
                final double expandValue = _expandAnimation.value;

                // Slide up and fade in
                final double currentY = yOffset * expandValue;

                return Positioned(
                  right: 0,
                  bottom: currentY,
                  child: Transform.scale(
                    scale: expandValue,
                    child: Opacity(opacity: expandValue, child: child),
                  ),
                );
              },
              child: _buildMenuItem(widget.items[index], index),
            );
          }),

          // Main FAB
          Positioned(
            right: 0,
            bottom: 0,
            child: FloatingActionButton(
              heroTag: 'main_fab',
              onPressed: widget.onToggle,
              tooltip: 'Options',
              backgroundColor: AppColors.primary,
              child: AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value * 2 * math.pi,
                    child: child,
                  );
                },
                child: const Icon(Icons.add, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(FanMenuItem item, int index) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          item.onTap();
          widget.onToggle(); // Close menu after selection
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Label on the left
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                item.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Icon button on the right
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: item.color ?? AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (item.color ?? AppColors.primary).withValues(
                      alpha: 0.4,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(item.icon, color: Colors.white, size: 26),
            ),
          ],
        ),
      ),
    );
  }
}
