import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../models/user_model.dart';

class AdminUsersDetailScreen extends StatefulWidget {
  const AdminUsersDetailScreen({super.key});

  @override
  State<AdminUsersDetailScreen> createState() => _AdminUsersDetailScreenState();
}

class _AdminUsersDetailScreenState extends State<AdminUsersDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<UserModel> _filter(List<UserModel> users) {
    switch (_tabController.index) {
      case 1:
        return users.where((u) => u.role == UserRole.admin).toList();
      case 2:
        return users.where((u) => u.role == UserRole.owner).toList();
      case 3:
        return users.where((u) => u.role == UserRole.user).toList();
      default:
        return users;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final allUsers = provider.allUsers;
    final filtered = _filter(allUsers);
    final tabs = ['All', 'Admins', 'Owners', 'Drivers'];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF5B4CFF), Color(0xFF7C3AED)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Users',
                                style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1)),
                            const SizedBox(height: 4),
                            Text('Manage all platform users',
                                style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Colors.white.withValues(alpha: 0.85))),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textHint,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w500),
                  tabs: List.generate(4, (i) => Tab(text: tabs[i])),
                ),
              ),
            ),
          ),
        ],
        body: filtered.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle),
                      child: Icon(Icons.people_outline,
                          size: 40,
                          color: AppColors.primary.withValues(alpha: 0.4)),
                    ),
                    const SizedBox(height: 16),
                    Text('No users found',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text('Try a different filter',
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: AppColors.textHint)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                itemCount: filtered.length,
                itemBuilder: (_, i) => _buildUserCard(filtered[i]),
              ),
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    final roleColor = _roleColor(user.role);
    final roleLabel = _roleLabel(user.role);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Gradient-ring avatar
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [roleColor, roleColor.withValues(alpha: 0.4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
              ),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: roleColor),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name,
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(user.email,
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.textSecondary)),
                  if (user.phone.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(user.phone,
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: AppColors.textHint)),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _statChip(Icons.calendar_today_outlined,
                          '${user.totalBookings}'),
                      if (user.role == UserRole.owner) ...[
                        _statChip(Icons.local_parking, '${user.totalParkings}'),
                        _statChip(Icons.account_balance_wallet_outlined,
                            '₹${user.earnings.toStringAsFixed(0)}'),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      roleColor.withValues(alpha: 0.15),
                      roleColor.withValues(alpha: 0.08)
                    ]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(roleLabel,
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: roleColor)),
                ),
                if (user.role == UserRole.owner) ...[
                  const SizedBox(height: 6),
                  _approvalBadge(user),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.textHint),
          const SizedBox(width: 4),
          Text(text,
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _approvalBadge(UserModel user) {
    Color c;
    String t;
    switch (user.approvalStatus) {
      case ApprovalStatus.approved:
        c = AppColors.success;
        t = 'Approved';
        break;
      case ApprovalStatus.pending:
        c = AppColors.warning;
        t = 'Pending';
        break;
      case ApprovalStatus.rejected:
        c = AppColors.error;
        t = 'Rejected';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: c.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(t,
              style: GoogleFonts.poppins(
                  fontSize: 10, fontWeight: FontWeight.w600, color: c)),
        ],
      ),
    );
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.owner:
        return 'Owner';
      case UserRole.user:
        return 'Driver';
    }
  }

  Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppColors.error;
      case UserRole.owner:
        return AppColors.accent;
      case UserRole.user:
        return AppColors.info;
    }
  }
}
