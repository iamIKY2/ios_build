import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/home_screen.dart';
import '../screens/student/tasks_screen.dart';
import '../screens/student/checkin_gacha_screen.dart';
import '../screens/student/handbook_screen.dart';
import '../screens/student/chat_screen.dart';
import '../widgets/sync_status_banner.dart';

class StudentNav extends StatefulWidget {
  const StudentNav({super.key});

  static StudentNavState? of(BuildContext context) =>
      context.findAncestorStateOfType<StudentNavState>();

  static void switchToTab(BuildContext context, int index) {
    context.findAncestorStateOfType<StudentNavState>()?.switchToTab(index);
  }

  @override
  State<StudentNav> createState() => StudentNavState();
}

class StudentNavState extends State<StudentNav> {
  int _currentIndex = 0;

  void switchToTab(int index) {
    if (mounted) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const TasksScreen(),
    const CheckinGachaScreen(),
    const HandbookScreen(),
    const ChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          const SafeArea(
            bottom: false,
            child: SyncStatusBanner(),
          ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                for (int i = 0; i < _screens.length; i++)
                  TickerMode(
                    enabled: _currentIndex == i,
                    child: _screens[i],
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: RepaintBoundary(
        child: _buildLiquidGlassBottomNav(),
      ),
    );
  }

  Widget _buildLiquidGlassBottomNav() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    // Trên iPhone 16 (bottomInset ~34px), SafeArea bottom mặc định cộng dồn với margin
    // làm dock bị đẩy lên 52px (quá cao). Tắt SafeArea bottom và tinh chỉnh margin đáy
    // giúp thanh dock hạ xuống vừa vặn sát đáy.
    final bottomMargin = bottomInset > 0 ? 8.0 : 12.0;

    return Padding(
      padding: EdgeInsets.only(left: 14, right: 14, bottom: bottomMargin),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.45)
                    : const Color(0xFF8C6A3C).withValues(alpha: 0.12),
                blurRadius: 28,
                offset: const Offset(0, 10),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.60),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: Container(
                height: 68,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF1E283C).withValues(alpha: 0.70),
                            const Color(0xFF111726).withValues(alpha: 0.60),
                            const Color(0xFF090D16).withValues(alpha: 0.50),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.90),
                            const Color(0xFFFFFBF2).withValues(alpha: 0.75),
                            const Color(0xFFF6EAD7).withValues(alpha: 0.60),
                          ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.16)
                        : Colors.white.withValues(alpha: 0.85),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Tổng quan'),
                    _buildNavItem(1, Icons.fact_check_rounded, Icons.fact_check_outlined, 'Nhiệm vụ'),
                    _buildCenterNavItem(2, Icons.auto_awesome_rounded, 'Điểm danh'),
                    _buildNavItem(3, Icons.menu_book_rounded, Icons.menu_book_outlined, 'Cẩm nang'),
                    _buildNavItem(4, Icons.smart_toy_rounded, Icons.smart_toy_outlined, 'AI Chat'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark ? AppTheme.textMuted : AppTheme.textSecondaryLight;
    final activeColor = AppTheme.primary;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(20),
      splashColor: AppTheme.primary.withValues(alpha: 0.1),
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: isDark ? 0.20 : 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(
                  color: activeColor.withValues(alpha: 0.25),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? activeColor : inactiveColor,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark ? AppTheme.textMuted : AppTheme.textSecondaryLight;
    final activeColor = AppTheme.primary;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(24),
      splashColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.accentAmber],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: isSelected ? 0.50 : 0.25),
                  blurRadius: isSelected ? 14 : 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}
