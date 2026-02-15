import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../models/user_model.dart';

/// Admin dashboard screen with stats, user management, parking approvals
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  String _formatRevenue(double amount) {
    if (amount >= 100000) return '\u20B9${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '\u20B9${(amount / 1000).toStringAsFixed(1)}K';
    return '\u20B9${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final pendingSpots = provider.pendingParkingSpots;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                      'Total Users', '${provider.totalUsersCount}', Icons.people, AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Total Spaces', '${provider.totalSpotsCount}',
                      Icons.local_parking, AppColors.accent),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Active Bookings', '${provider.activeBookingsCount}',
                      Icons.calendar_today, AppColors.success),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Revenue', _formatRevenue(provider.totalRevenue),
                      Icons.account_balance_wallet, AppColors.starYellow),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Quick Actions
            Text(
              'MANAGEMENT',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textHint,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              Icons.people_outline,
              'User Management',
              'View and manage all registered users',
              AppColors.primary,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const _UserListScreen()),
              ),
            ),
            const SizedBox(height: 10),
            _buildActionTile(
              Icons.verified_user_outlined,
              'Parking Approvals',
              'Review and approve new parking listings',
              AppColors.warning,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const _ParkingApprovalScreen()),
              ),
            ),
            const SizedBox(height: 10),
            _buildActionTile(
              Icons.analytics_outlined,
              'All Bookings',
              'View all platform bookings',
              AppColors.success,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const _AllBookingsScreen()),
              ),
            ),
            const SizedBox(height: 28),

            // Pending Approvals
            Text(
              'PENDING APPROVALS (${pendingSpots.length})',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textHint,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            if (pendingSpots.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('No pending approvals', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textHint)),
                ),
              )
            else
              ...pendingSpots.map((spot) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildApprovalCard(
                  'New Parking: ${spot.name}',
                  'Submitted by ${spot.ownerName}',
                  spot.address,
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, String subtitle,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textHint, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalCard(
      String title, String subtitle, String timeAgo) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.pending_actions,
                color: AppColors.warning, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  timeAgo,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: AppColors.textHint, size: 22),
        ],
      ),
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'User Management (${users.length})',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: users.isEmpty
          ? Center(child: Text('No users found', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textHint)))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final roleLabel = user.role == UserRole.owner ? 'Owner' : user.role == UserRole.admin ? 'Admin' : 'Driver';
                final roleColor = user.role == UserRole.owner ? AppColors.accent : user.role == UserRole.admin ? AppColors.error : AppColors.info;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          user.name.isNotEmpty ? user.name[0] : '?',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            Text(user.email, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: roleColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(roleLabel, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: roleColor)),
                      ),
                    ],
                  ),
                );
              },
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Parking Approvals (${pendingSpots.length})',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: pendingSpots.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: AppColors.success.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('All caught up!', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text('No pending parking approvals.', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textHint)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: pendingSpots.length,
              itemBuilder: (context, index) {
                final spot = pendingSpots[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          spot.imageUrl,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 120,
                            width: double.infinity,
                            color: AppColors.shimmerBase,
                            child: const Center(child: Icon(Icons.local_parking, size: 40, color: AppColors.textHint)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(spot.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                            child: Text('PENDING', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.warning)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('By ${spot.ownerName}', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                      Text(spot.address, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textHint)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildInfoChip('\u20B9${spot.pricePerHour.toStringAsFixed(0)}/hr'),
                          const SizedBox(width: 8),
                          _buildInfoChip(spot.type[0].toUpperCase() + spot.type.substring(1)),
                          const SizedBox(width: 8),
                          _buildInfoChip('${spot.capacity} spots'),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                provider.rejectParkingSpot(spot.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${spot.name} rejected', style: GoogleFonts.poppins()), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
                                );
                              },
                              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 12)),
                              child: Text('Reject', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                provider.approveParkingSpot(spot.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${spot.name} approved!', style: GoogleFonts.poppins()), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
                                );
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 12), elevation: 0),
                              child: Text('Approve', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
    );
  }
}

/// All Bookings screen for admin
class _AllBookingsScreen extends StatelessWidget {
  const _AllBookingsScreen();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final bookings = provider.allBookings;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('All Bookings (${bookings.length})', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        centerTitle: true,
      ),
      body: bookings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 64, color: AppColors.textHint.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  Text('No bookings yet', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final b = bookings[index];
                Color statusColor;
                switch (b.status) {
                  case 'confirmed': statusColor = AppColors.primary; break;
                  case 'active': statusColor = AppColors.success; break;
                  case 'completed': statusColor = AppColors.textSecondary; break;
                  default: statusColor = AppColors.error;
                }
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          (b.userName.isEmpty ? 'U' : b.userName[0]),
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.userName.isEmpty ? 'User' : b.userName, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            Text(b.parkingName, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\u20B9${b.totalPrice.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text(b.status.toUpperCase(), style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: statusColor)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
