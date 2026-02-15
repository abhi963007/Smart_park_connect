import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../models/user_model.dart';
import '../../services/local_storage_service.dart';
import 'admin_users_detail_screen.dart';
import 'admin_spaces_detail_screen.dart';
import 'admin_bookings_detail_screen.dart';
import 'admin_revenue_detail_screen.dart';

/// Admin dashboard screen with stats, user management, parking approvals
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  String _fmtRevenue(double a) {
    if (a >= 100000) return '\u20B9${(a / 100000).toStringAsFixed(1)}L';
    if (a >= 1000) return '\u20B9${(a / 1000).toStringAsFixed(1)}K';
    return '\u20B9${a.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final pendingSpots = provider.pendingParkingSpots;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title ──
              Center(
                child: Text('Admin Dashboard',
                    style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ),
              const SizedBox(height: 24),

              // ── Stat Cards Grid ──
              Row(children: [
                Expanded(child: _statCard(context, 'Total Users', '${provider.totalUsersCount}',
                    Icons.people_alt_outlined, AppColors.primary,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsersDetailScreen())))),
                const SizedBox(width: 12),
                Expanded(child: _statCard(context, 'Total Spaces', '${provider.totalSpotsCount}',
                    Icons.local_parking_outlined, AppColors.accent,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSpacesDetailScreen())))),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _statCard(context, 'Active Bookings', '${provider.activeBookingsCount}',
                    Icons.calendar_today_outlined, AppColors.success,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBookingsDetailScreen())))),
                const SizedBox(width: 12),
                Expanded(child: _statCard(context, 'Revenue', _fmtRevenue(provider.totalRevenue),
                    Icons.account_balance_wallet_outlined, AppColors.starYellow,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRevenueDetailScreen())))),
              ]),
              const SizedBox(height: 28),

              // ── Management Section ──
              Text('MANAGEMENT',
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textHint, letterSpacing: 1.2)),
              const SizedBox(height: 12),
              _mgmtTile(context, Icons.people_alt_outlined, 'User Management',
                  'View and manage all registered users', AppColors.primary,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _UserListScreen()))),
              const SizedBox(height: 10),
              _mgmtTile(context, Icons.verified_outlined, 'Parking Approvals',
                  'Review and approve new parking listings', AppColors.warning,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _ParkingApprovalScreen()))),
              const SizedBox(height: 10),
              _mgmtTile(context, Icons.business_center_outlined, 'Owner Approvals',
                  'Review and approve new owner registrations', AppColors.accent,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _OwnerApprovalScreen()))),
              const SizedBox(height: 10),
              _mgmtTile(context, Icons.calendar_month_outlined, 'All Bookings',
                  'View all platform bookings', AppColors.success,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _AllBookingsScreen()))),
              const SizedBox(height: 28),

              // ── Pending Approvals ──
              Text('PENDING APPROVALS (${pendingSpots.length})',
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textHint, letterSpacing: 1.2)),
              const SizedBox(height: 12),
              if (pendingSpots.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3))]),
                  child: Column(children: [
                    Container(width: 56, height: 56,
                      decoration: BoxDecoration(color: AppColors.success.withOpacity(0.08), shape: BoxShape.circle),
                      child: Icon(Icons.check_circle_outline, size: 28, color: AppColors.success.withOpacity(0.5))),
                    const SizedBox(height: 10),
                    Text('All caught up!', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text('No pending approvals', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textHint)),
                  ]),
                )
              else
                ...pendingSpots.map((spot) => _pendingCard(spot)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Stat Card ──
  Widget _statCard(BuildContext context, String label, String value, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color.withOpacity(0.15), color.withOpacity(0.06)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint.withOpacity(0.5)),
            ]),
            const SizedBox(height: 14),
            Text(value, style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1)),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  // ── Management Tile ──
  Widget _mgmtTile(BuildContext context, IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withOpacity(0.15), color.withOpacity(0.06)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
          ])),
          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textHint.withOpacity(0.4)),
        ]),
      ),
    );
  }

  // ── Pending Approval Card ──
  Widget _pendingCard(dynamic spot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withOpacity(0.25)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.warning.withOpacity(0.15), AppColors.warning.withOpacity(0.06)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.pending_actions, color: AppColors.warning, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('New Parking: ${spot.name}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Text('Submitted by ${spot.ownerName}', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
          Text(spot.address, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textHint)),
        ])),
        Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint.withOpacity(0.4)),
      ]),
    );
  }
}

/// User list screen for admin - dynamic
class _UserListScreen extends StatelessWidget {
  const _UserListScreen();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final users = provider.allUsers;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF5B4CFF), Color(0xFF7C3AED)])),
                child: SafeArea(child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${users.length}', style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, height: 1)),
                    const SizedBox(height: 4),
                    Text('Registered Users', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.85))),
                  ]),
                )),
              ),
            ),
            bottom: PreferredSize(preferredSize: const Size.fromHeight(20),
              child: Container(height: 20, decoration: const BoxDecoration(color: Color(0xFFF8F9FE), borderRadius: BorderRadius.vertical(top: Radius.circular(24))))),
          ),
          users.isEmpty
              ? SliverFillRemaining(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(width: 64, height: 64, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), shape: BoxShape.circle),
                    child: Icon(Icons.people_outline, size: 32, color: AppColors.primary.withOpacity(0.4))),
                  const SizedBox(height: 12),
                  Text('No users found', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                ])))
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  sliver: SliverList(delegate: SliverChildBuilderDelegate((_, i) {
                    final user = users[i];
                    final rc = user.role == UserRole.owner ? AppColors.accent : user.role == UserRole.admin ? AppColors.error : AppColors.info;
                    final rl = user.role == UserRole.owner ? 'Owner' : user.role == UserRole.admin ? 'Admin' : 'Driver';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))]),
                      child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [rc, rc.withOpacity(0.4)])),
                          child: CircleAvatar(radius: 22, backgroundColor: Colors.white,
                            child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: rc, fontSize: 16))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(user.name, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          Text(user.email, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                          if (user.phone.isNotEmpty) Text(user.phone, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textHint)),
                        ])),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(gradient: LinearGradient(colors: [rc.withOpacity(0.15), rc.withOpacity(0.08)]), borderRadius: BorderRadius.circular(8)),
                          child: Text(rl, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: rc)),
                        ),
                      ])),
                    );
                  }, childCount: users.length)),
                ),
        ],
      ),
    );
  }
}

/// Parking approval screen for admin - dynamic
class _ParkingApprovalScreen extends StatelessWidget {
  const _ParkingApprovalScreen();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final pendingSpots = provider.pendingParkingSpots;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppColors.warning,
            leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF59E0B), Color(0xFFD97706)])),
                child: SafeArea(child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${pendingSpots.length}', style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, height: 1)),
                    const SizedBox(height: 4),
                    Text('Pending Parking Approvals', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.85))),
                  ]),
                )),
              ),
            ),
            bottom: PreferredSize(preferredSize: const Size.fromHeight(20),
              child: Container(height: 20, decoration: const BoxDecoration(color: Color(0xFFF8F9FE), borderRadius: BorderRadius.vertical(top: Radius.circular(24))))),
          ),
          pendingSpots.isEmpty
              ? SliverFillRemaining(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(width: 72, height: 72, decoration: BoxDecoration(color: AppColors.success.withOpacity(0.08), shape: BoxShape.circle),
                    child: Icon(Icons.check_circle_outline, size: 36, color: AppColors.success.withOpacity(0.5))),
                  const SizedBox(height: 14),
                  Text('All caught up!', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text('No pending parking approvals', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textHint)),
                ])))
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  sliver: SliverList(delegate: SliverChildBuilderDelegate((_, i) {
                    final spot = pendingSpots[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 4))]),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        // Image with overlay
                        Stack(children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            child: Image.network(spot.imageUrl, height: 130, width: double.infinity, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(height: 130, width: double.infinity,
                                decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.warning.withOpacity(0.1), AppColors.warning.withOpacity(0.05)]),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
                                child: const Center(child: Icon(Icons.local_parking, size: 48, color: AppColors.textHint)))),
                          ),
                          Positioned.fill(child: Container(decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.35)])))),
                          Positioned(top: 12, right: 12, child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(8)),
                            child: Text('PENDING', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5)))),
                          Positioned(bottom: 12, left: 12, child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                            child: Text('\u20B9${spot.pricePerHour.toStringAsFixed(0)}/hr', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)))),
                        ]),
                        Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(spot.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          Row(children: [const Icon(Icons.person_outline, size: 14, color: AppColors.textHint), const SizedBox(width: 4),
                            Text(spot.ownerName, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary))]),
                          const SizedBox(height: 2),
                          Row(children: [const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textHint), const SizedBox(width: 4),
                            Expanded(child: Text(spot.address, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textHint), maxLines: 1, overflow: TextOverflow.ellipsis))]),
                          const SizedBox(height: 10),
                          Wrap(spacing: 8, runSpacing: 6, children: [
                            _chip(Icons.directions_car_outlined, spot.type[0].toUpperCase() + spot.type.substring(1)),
                            _chip(Icons.event_seat_outlined, '${spot.capacity} spots'),
                          ]),
                          const SizedBox(height: 14),
                          Row(children: [
                            Expanded(child: OutlinedButton.icon(
                              onPressed: () { provider.rejectParkingSpot(spot.id); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${spot.name} rejected'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating)); },
                              icon: const Icon(Icons.close, size: 16), label: Text('Reject', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)))),
                            const SizedBox(width: 10),
                            Expanded(child: ElevatedButton.icon(
                              onPressed: () { provider.approveParkingSpot(spot.id); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${spot.name} approved!'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating)); },
                              icon: const Icon(Icons.check, size: 16), label: Text('Approve', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12), elevation: 0))),
                          ]),
                        ])),
                      ]),
                    );
                  }, childCount: pendingSpots.length)),
                ),
        ],
      ),
    );
  }

  static Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: AppColors.textHint), const SizedBox(width: 4),
        Text(text, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
      ]),
    );
  }
}

/// Owner approval screen for admin - manage pending owner registrations
class _OwnerApprovalScreen extends StatelessWidget {
  const _OwnerApprovalScreen();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserModel>>(
      future: LocalStorageService.getPendingOwnerApprovals(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(backgroundColor: AppColors.backgroundLight,
            body: const Center(child: CircularProgressIndicator(color: AppColors.accent)));
        }
        final pendingOwners = snapshot.data ?? [];

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                backgroundColor: AppColors.accent,
                leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF7C3AED), Color(0xFF5B4CFF)])),
                    child: SafeArea(child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${pendingOwners.length}', style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, height: 1)),
                        const SizedBox(height: 4),
                        Text('Pending Owner Approvals', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.85))),
                      ]),
                    )),
                  ),
                ),
                bottom: PreferredSize(preferredSize: const Size.fromHeight(20),
                  child: Container(height: 20, decoration: const BoxDecoration(color: Color(0xFFF8F9FE), borderRadius: BorderRadius.vertical(top: Radius.circular(24))))),
              ),
              pendingOwners.isEmpty
                  ? SliverFillRemaining(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(width: 72, height: 72, decoration: BoxDecoration(color: AppColors.success.withOpacity(0.08), shape: BoxShape.circle),
                        child: Icon(Icons.check_circle_outline, size: 36, color: AppColors.success.withOpacity(0.5))),
                      const SizedBox(height: 14),
                      Text('All caught up!', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text('No pending owner approvals', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textHint)),
                    ])))
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      sliver: SliverList(delegate: SliverChildBuilderDelegate((_, i) {
                        final owner = pendingOwners[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))]),
                          child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Container(
                                padding: const EdgeInsets.all(2.5),
                                decoration: BoxDecoration(shape: BoxShape.circle,
                                  gradient: LinearGradient(colors: [AppColors.accent, AppColors.accent.withOpacity(0.4)])),
                                child: CircleAvatar(radius: 26, backgroundColor: Colors.white,
                                  child: Text(owner.name.isNotEmpty ? owner.name[0].toUpperCase() : 'O',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.accent, fontSize: 20))),
                              ),
                              const SizedBox(width: 14),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(owner.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                Text(owner.email, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                                if (owner.phone.isNotEmpty) Text(owner.phone, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textHint)),
                              ])),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.warning.withOpacity(0.3), width: 0.5)),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  Container(width: 6, height: 6, decoration: BoxDecoration(color: AppColors.warning, shape: BoxShape.circle)),
                                  const SizedBox(width: 5),
                                  Text('Pending', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.warning)),
                                ]),
                              ),
                            ]),
                            const SizedBox(height: 16),
                            Row(children: [
                              Expanded(child: OutlinedButton.icon(
                                onPressed: () async {
                                  final error = await LocalStorageService.rejectOwner(owner.id);
                                  if (context.mounted) {
                                    if (error != null) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: AppColors.error)); }
                                    else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${owner.name} rejected'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating));
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const _OwnerApprovalScreen())); }
                                  }
                                },
                                icon: const Icon(Icons.close, size: 16), label: Text('Reject', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                                style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)))),
                              const SizedBox(width: 10),
                              Expanded(child: ElevatedButton.icon(
                                onPressed: () async {
                                  final error = await LocalStorageService.approveOwner(owner.id);
                                  if (context.mounted) {
                                    if (error != null) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: AppColors.error)); }
                                    else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${owner.name} approved!'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating));
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const _OwnerApprovalScreen())); }
                                  }
                                },
                                icon: const Icon(Icons.check, size: 16), label: Text('Approve', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12), elevation: 0))),
                            ]),
                          ])),
                        );
                      }, childCount: pendingOwners.length)),
                    ),
            ],
          ),
        );
      },
    );
  }
}

/// All Bookings screen for admin
class _AllBookingsScreen extends StatelessWidget {
  const _AllBookingsScreen();

  Color _sc(String s) {
    switch (s) { case 'confirmed': return AppColors.primary; case 'active': return AppColors.success; case 'completed': return AppColors.textSecondary; default: return AppColors.error; }
  }

  IconData _si(String s) {
    switch (s) { case 'confirmed': return Icons.schedule; case 'active': return Icons.play_circle_outline; case 'completed': return Icons.check_circle_outline; default: return Icons.cancel_outlined; }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final bookings = provider.allBookings;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppColors.success,
            leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF10B981), Color(0xFF059669)])),
                child: SafeArea(child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${bookings.length}', style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, height: 1)),
                    const SizedBox(height: 4),
                    Text('All Bookings', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.85))),
                  ]),
                )),
              ),
            ),
            bottom: PreferredSize(preferredSize: const Size.fromHeight(20),
              child: Container(height: 20, decoration: const BoxDecoration(color: Color(0xFFF8F9FE), borderRadius: BorderRadius.vertical(top: Radius.circular(24))))),
          ),
          bookings.isEmpty
              ? SliverFillRemaining(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(width: 72, height: 72, decoration: BoxDecoration(color: AppColors.success.withOpacity(0.08), shape: BoxShape.circle),
                    child: Icon(Icons.calendar_today, size: 32, color: AppColors.success.withOpacity(0.4))),
                  const SizedBox(height: 14),
                  Text('No bookings yet', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text('Bookings will appear here', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textHint)),
                ])))
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  sliver: SliverList(delegate: SliverChildBuilderDelegate((_, i) {
                    final b = bookings[i];
                    final sc = _sc(b.status);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))]),
                      child: Column(children: [
                        Container(height: 3, decoration: BoxDecoration(color: sc, borderRadius: const BorderRadius.vertical(top: Radius.circular(18)))),
                        Padding(padding: const EdgeInsets.all(14), child: Row(children: [
                          Container(
                            padding: const EdgeInsets.all(2.5),
                            decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [sc, sc.withOpacity(0.4)])),
                            child: CircleAvatar(radius: 20, backgroundColor: Colors.white,
                              child: Text(b.userName.isEmpty ? 'U' : b.userName[0].toUpperCase(),
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: sc, fontSize: 14))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(b.userName.isEmpty ? 'User' : b.userName, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            Text(b.parkingName, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                          ])),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text('\u20B9${b.totalPrice.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: sc.withOpacity(0.3), width: 0.5)),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(_si(b.status), size: 11, color: sc),
                                const SizedBox(width: 4),
                                Text(b.status.toUpperCase(), style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: sc, letterSpacing: 0.3)),
                              ]),
                            ),
                          ]),
                        ])),
                      ]),
                    );
                  }, childCount: bookings.length)),
                ),
        ],
      ),
    );
  }
}
