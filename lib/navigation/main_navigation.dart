import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/user_model.dart';
import '../providers/app_provider.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/saved_screen.dart';
import '../screens/booking/bookings_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/owner/owner_dashboard_screen.dart';
import '../screens/owner/owner_pending_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';

/// Main navigation shell with role-based bottom navigation bar
/// Driver: Explore, Saved, Bookings, Profile
/// Owner: Explore, Dashboard, Bookings, Profile
/// Admin: Dashboard, Explore, Bookings, Profile
class MainNavigation extends StatefulWidget {
  final int initialIndex;
  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  /// Get screens based on user role
  List<Widget> _getScreens(UserRole role, UserModel user) {
    switch (role) {
      case UserRole.admin:
        return const [
          AdminDashboardScreen(),
          HomeScreen(),
          BookingsScreen(),
          ProfileScreen(),
        ];
      case UserRole.owner:
        // Check if owner is approved before allowing dashboard access
        final dashboardScreen = user.canPerformOwnerActions 
            ? const OwnerDashboardScreen()
            : const OwnerPendingScreen();
        return [
          const HomeScreen(),
          dashboardScreen,
          const BookingsScreen(),
          const ProfileScreen(),
        ];
      case UserRole.user:
      default:
        return const [
          HomeScreen(),
          SavedScreen(),
          BookingsScreen(),
          ProfileScreen(),
        ];
    }
  }

  /// Get nav items based on user role
  List<_NavItemData> _getNavItems(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return [
          _NavItemData(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
          _NavItemData(Icons.explore_outlined, Icons.explore, 'Explore'),
          _NavItemData(Icons.calendar_today_outlined, Icons.calendar_today, 'Bookings'),
          _NavItemData(Icons.person_outline, Icons.person, 'Profile'),
        ];
      case UserRole.owner:
        return [
          _NavItemData(Icons.explore_outlined, Icons.explore, 'Explore'),
          _NavItemData(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
          _NavItemData(Icons.calendar_today_outlined, Icons.calendar_today, 'Bookings'),
          _NavItemData(Icons.person_outline, Icons.person, 'Profile'),
        ];
      case UserRole.user:
      default:
        return [
          _NavItemData(Icons.explore_outlined, Icons.explore, 'Explore'),
          _NavItemData(Icons.favorite_border, Icons.favorite, 'Saved'),
          _NavItemData(Icons.calendar_today_outlined, Icons.calendar_today, 'Bookings'),
          _NavItemData(Icons.person_outline, Icons.person, 'Profile'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;
    final role = user.role;
    final screens = _getScreens(role, user);
    final navItems = _getNavItems(role);

    // Clamp index to valid range
    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(navItems.length, (index) {
                return _buildNavItem(
                  index,
                  navItems[index].icon,
                  navItems[index].activeIcon,
                  navItems[index].label,
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  /// Regular nav item
  Widget _buildNavItem(
      int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.textHint,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItemData(this.icon, this.activeIcon, this.label);
}
