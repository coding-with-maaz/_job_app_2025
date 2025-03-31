import 'package:flutter/material.dart';

class AnimatedTabBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AnimatedTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem(
                context,
                0,
                Icons.home_outlined,
                Icons.home,
                'Home',
              ),
              _buildTabItem(context, 1, Icons.work_outline, Icons.work, 'Jobs'),
              _buildTabItem(
                context,
                2,
                Icons.today_outlined,
                Icons.today,
                'Today',
              ),
              _buildTabItem(
                context,
                3,
                Icons.favorite_border,
                Icons.favorite,
                'Saved',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(
    BuildContext context,
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary.withAlpha(25)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(153),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(153),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
