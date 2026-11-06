import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marketers/pages/chat_list_page.dart';
import 'package:marketers/pages/home.dart';
import 'package:marketers/pages/notification.dart';
import 'package:marketers/pages/profile.dart';
import 'package:marketers/service/colors.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}

class _MainShellState extends ConsumerState<MainShell>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 2;

  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  final List<Widget> _pages = const [
    NotificationPage(),
    ChatListPage(),
    Home(),
    ProfilePage(),
  ];

  static const _items = [
    _NavItem(
      Icons.notifications_outlined,
      Icons.notifications_rounded,
      'Alerts',
    ),
    _NavItem(
      Icons.chat_bubble_outline_rounded,
      Icons.chat_bubble_rounded,
      'Chats',
    ),
    _NavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
    _NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _glowAnimation = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _select(int index) {
    if (index == _selectedIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  // ─────────────────────────── NAV BAR ───────────────────────────

  Widget _buildNavBar() {
    final media = MediaQuery.of(context);

    // Hide the floating bar while the keyboard is open (chat, search...).
    if (media.viewInsets.bottom > 0) return const SizedBox.shrink();

    final bottomInset = media.padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        bottomInset > 0 ? bottomInset : 16,
      ),
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, _) {
          final glow = _glowAnimation.value;
          return Container(
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: AppColors.pearl.withValues(alpha: 0.14 + glow * 0.22),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.pearl.withValues(alpha: 0.06 + glow * 0.10),
                  blurRadius: 28,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: AppColors.surface.withValues(alpha: 0.82),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const selectedWidth = 122.0;
                      final otherWidth =
                          (constraints.maxWidth - selectedWidth) /
                          (_items.length - 1);

                      return Row(
                        children: List.generate(_items.length, (index) {
                          final selected = index == _selectedIndex;
                          return _buildNavItem(
                            index: index,
                            selected: selected,
                            width: selected ? selectedWidth : otherWidth,
                          );
                        }),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required bool selected,
    required double width,
  }) {
    final item = _items[index];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _select(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        width: width,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: selected
              ? LinearGradient(
                  colors: [
                    AppColors.pearl,
                    AppColors.pearl.withValues(alpha: 0.82),
                  ],
                )
              : null,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.pearl.withValues(alpha: 0.38),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                selected ? item.activeIcon : item.icon,
                key: ValueKey(selected),
                size: 24,
                color: selected ? Colors.black : AppColors.textDisabled,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  item.label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
