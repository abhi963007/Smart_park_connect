import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/user_model.dart';
import '../../providers/app_provider.dart';
import '../../navigation/main_navigation.dart';
import '../auth/phone_auth_screen.dart' show LoginScreen;
import '../home/saved_screen.dart';
import 'payment_methods_screen.dart';
import 'edit_profile_screen.dart';

/// User Profile & Settings screen with avatar, activity, preferences, system
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;
    final rc = _roleBadgeColor(user.role);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 24, 0, 24),
          child: Column(
            children: [
              // ── Avatar ──
              GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 116, height: 116,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.18), AppColors.primary.withOpacity(0.06)]),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: CircleAvatar(
                        radius: 54,
                        backgroundColor: Colors.white,
                        backgroundImage: _getAvatarImage(user),
                        onBackgroundImageError: _getAvatarImage(user) != null ? (_, __) {} : null,
                        child: _getAvatarImage(user) == null
                            ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.w700, color: AppColors.primary))
                            : null,
                      ),
                    ),
                    Positioned(bottom: 4, right: 4, child: Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 15),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(user.name, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              if (user.email.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(user.email, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
              ],
              const SizedBox(height: 10),
              // Role badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [rc.withOpacity(0.12), rc.withOpacity(0.05)]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: rc.withOpacity(0.25)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_roleIcon(user.role), color: rc, size: 14),
                  const SizedBox(width: 5),
                  Text(user.roleDisplayName, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: rc, letterSpacing: 0.5)),
                ]),
              ),
              const SizedBox(height: 28),

              // ── MY ACTIVITY ──
              _sectionHeader(AppStrings.myActivity),
              _settingsGroup([
                _SettingItem(icon: Icons.calendar_today_outlined, iconColor: AppColors.primary, title: AppStrings.myBookings,
                  onTap: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainNavigation(initialIndex: 2)), (r) => false)),
                _SettingItem(icon: Icons.local_parking_outlined, iconColor: AppColors.accent, title: AppStrings.myParkings,
                  onTap: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainNavigation(initialIndex: 1)), (r) => false)),
              ]),
              const SizedBox(height: 14),

              // ── PREFERENCES ──
              _sectionHeader(AppStrings.preferences),
              _settingsGroup([
                _SettingItem(icon: Icons.payment_outlined, iconColor: AppColors.info, title: AppStrings.paymentMethods,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()))),
                _SettingItem(icon: Icons.favorite_outline, iconColor: Colors.pink, title: AppStrings.favoriteSpots,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SavedScreen()))),
              ]),
              const SizedBox(height: 14),

              // ── SYSTEM ──
              _sectionHeader(AppStrings.system),
              _settingsGroup([
                _SettingItem(icon: Icons.help_outline, iconColor: AppColors.accent, title: AppStrings.helpSupport,
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Help & Support coming soon'), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))),
                _SettingItem(icon: Icons.info_outline, iconColor: AppColors.textSecondary, title: 'About',
                  onTap: () => showAboutDialog(context: context, applicationName: 'Smart Park Connect', applicationVersion: AppStrings.appVersion,
                    children: [Text('Intelligent Parking Management System connecting drivers with private parking owners.', style: GoogleFonts.poppins(fontSize: 14))])),
              ]),
              const SizedBox(height: 24),

              // ── Logout ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(width: double.infinity, height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () { provider.logout(); Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false); },
                    icon: const Icon(Icons.logout, color: AppColors.error, size: 20),
                    label: Text(AppStrings.logOut, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.error)),
                    style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.error.withOpacity(0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text('Smart Park Connect ${AppStrings.appVersion}', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textHint)),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider? _getAvatarImage(UserModel user) {
    if (user.avatarUrl.isEmpty) return null;
    if (user.avatarUrl.startsWith('/') || user.avatarUrl.startsWith('C:')) {
      final file = File(user.avatarUrl);
      if (file.existsSync()) return FileImage(file);
      return null;
    }
    return NetworkImage(user.avatarUrl);
  }

  Color _roleBadgeColor(UserRole role) {
    switch (role) { case UserRole.admin: return AppColors.error; case UserRole.owner: return AppColors.success; case UserRole.user: return AppColors.primary; }
  }

  IconData _roleIcon(UserRole role) {
    switch (role) { case UserRole.admin: return Icons.admin_panel_settings; case UserRole.owner: return Icons.home_work; case UserRole.user: return Icons.directions_car; }
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
      child: Align(alignment: Alignment.centerLeft,
        child: Text(title, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textHint, letterSpacing: 1.2))),
    );
  }

  Widget _settingsGroup(List<_SettingItem> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(children: items.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        return Column(children: [
          InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.vertical(
              top: i == 0 ? const Radius.circular(18) : Radius.zero,
              bottom: i == items.length - 1 ? const Radius.circular(18) : Radius.zero),
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [item.iconColor.withOpacity(0.15), item.iconColor.withOpacity(0.05)]),
                  borderRadius: BorderRadius.circular(12)),
                child: Icon(item.icon, color: item.iconColor, size: 20)),
              const SizedBox(width: 14),
              Expanded(child: Text(item.title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
              if (item.trailing != null) ...[item.trailing!, const SizedBox(width: 8)],
              Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textHint.withOpacity(0.4), size: 16),
            ])),
          ),
          if (i < items.length - 1) Divider(height: 1, indent: 70, color: AppColors.divider.withOpacity(0.5)),
        ]);
      }).toList()),
    );
  }
}

class _SettingItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.trailing,
    required this.onTap,
  });
}
