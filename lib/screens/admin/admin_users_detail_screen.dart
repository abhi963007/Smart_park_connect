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
  String? _currentAdminId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get current admin ID from provider
    final provider = context.read<AppProvider>();
    _currentAdminId = provider.currentUser.id;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<UserModel> _filter(List<UserModel> users) {
    // Filter out admins from the list - only show owners and drivers
    final nonAdminUsers = users.where((u) => u.role != UserRole.admin).toList();

    switch (_tabController.index) {
      case 1:
        return nonAdminUsers.where((u) => u.role == UserRole.owner).toList();
      case 2:
        return nonAdminUsers.where((u) => u.role == UserRole.user).toList();
      default:
        return nonAdminUsers;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final allUsers = provider.allUsers;
    final filtered = _filter(allUsers);
    final tabs = ['All', 'Owners', 'Drivers'];

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
                  tabs: List.generate(3, (i) => Tab(text: tabs[i])),
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
                const SizedBox(height: 8),
                // Action buttons - hide delete for current admin
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _actionButton(
                      icon: Icons.edit,
                      color: AppColors.primary,
                      onTap: () => _showEditUserDialog(user),
                    ),
                    // Only show delete button if not the current admin
                    if (user.id != _currentAdminId) ...[
                      const SizedBox(width: 8),
                      _actionButton(
                        icon: Icons.delete_outline,
                        color: AppColors.error,
                        onTap: () => _showDeleteConfirmation(user),
                      ),
                    ],
                  ],
                ),
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

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: color.withValues(alpha: 0.2),
        highlightColor: color.withValues(alpha: 0.1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
      ),
    );
  }

  void _showEditUserDialog(UserModel user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phone);
    UserRole selectedRole = user.role;
    ApprovalStatus selectedApproval = user.approvalStatus;
    final formKey = GlobalKey<FormState>();
    bool isUpdating = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 16,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _roleColor(user.role),
                              _roleColor(user.role).withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Edit User Profile',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Update user information and permissions',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Form Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Personal Information Section
                          Text(
                            'Personal Information',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Name Field
                          TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              hintText: 'Enter full name',
                              prefixIcon: Icon(Icons.person_outline,
                                  color: AppColors.primary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: AppColors.cardBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: AppColors.cardBorder
                                        .withValues(alpha: 0.5)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: AppColors.primary, width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: AppColors.error, width: 2),
                              ),
                              filled: true,
                              fillColor: AppColors.backgroundLight
                                  .withValues(alpha: 0.3),
                            ),
                            validator: (v) {
                              if (v?.trim().isEmpty == true) {
                                return 'Name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Email Field
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              hintText: 'Enter email address',
                              prefixIcon: Icon(Icons.email_outlined,
                                  color: AppColors.primary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: AppColors.cardBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: AppColors.cardBorder
                                        .withValues(alpha: 0.5)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: AppColors.primary, width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: AppColors.error, width: 2),
                              ),
                              filled: true,
                              fillColor: AppColors.backgroundLight
                                  .withValues(alpha: 0.3),
                            ),
                            validator: (v) {
                              if (v?.trim().isEmpty == true) {
                                return 'Email is required';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(v!)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Phone Field
                          TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              hintText: 'Enter phone number',
                              prefixIcon: Icon(Icons.phone_outlined,
                                  color: AppColors.primary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: AppColors.cardBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: AppColors.cardBorder
                                        .withValues(alpha: 0.5)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: AppColors.primary, width: 2),
                              ),
                              filled: true,
                              fillColor: AppColors.backgroundLight
                                  .withValues(alpha: 0.3),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Role & Permissions Section
                          Text(
                            'Role & Permissions',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Role Dropdown
                          DropdownButtonFormField<UserRole>(
                            initialValue: selectedRole,
                            decoration: InputDecoration(
                              labelText: 'User Role',
                              prefixIcon: Icon(
                                  Icons.admin_panel_settings_outlined,
                                  color: AppColors.primary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: AppColors.cardBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: AppColors.cardBorder
                                        .withValues(alpha: 0.5)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: AppColors.primary, width: 2),
                              ),
                              filled: true,
                              fillColor: AppColors.backgroundLight
                                  .withValues(alpha: 0.3),
                            ),
                            items: UserRole.values
                                .map((role) => DropdownMenuItem(
                                      value: role,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: _roleColor(role),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _roleLabel(role),
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                            onChanged: (role) =>
                                setState(() => selectedRole = role!),
                          ),

                          // Owner Approval Status (conditional)
                          if (selectedRole == UserRole.owner) ...[
                            const SizedBox(height: 16),
                            DropdownButtonFormField<ApprovalStatus>(
                              initialValue: selectedApproval,
                              decoration: InputDecoration(
                                labelText: 'Approval Status',
                                prefixIcon: Icon(Icons.verified_user_outlined,
                                    color: AppColors.primary),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: AppColors.cardBorder),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: AppColors.cardBorder
                                          .withValues(alpha: 0.5)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: AppColors.primary, width: 2),
                                ),
                                filled: true,
                                fillColor: AppColors.backgroundLight
                                    .withValues(alpha: 0.3),
                              ),
                              items: ApprovalStatus.values.map((status) {
                                Color statusColor;
                                switch (status) {
                                  case ApprovalStatus.approved:
                                    statusColor = AppColors.success;
                                    break;
                                  case ApprovalStatus.pending:
                                    statusColor = AppColors.warning;
                                    break;
                                  case ApprovalStatus.rejected:
                                    statusColor = AppColors.error;
                                    break;
                                }
                                return DropdownMenuItem(
                                  value: status,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: statusColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        status.name.toUpperCase(),
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          color: statusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (status) =>
                                  setState(() => selectedApproval = status!),
                            ),
                          ],

                          const SizedBox(height: 32),

                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: isUpdating
                                      ? null
                                      : () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: AppColors.cardBorder
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    backgroundColor: Colors.transparent,
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: isUpdating
                                      ? null
                                      : () async {
                                          if (formKey.currentState!
                                              .validate()) {
                                            setState(() => isUpdating = true);

                                            final provider =
                                                context.read<AppProvider>();
                                            final navigator =
                                                Navigator.of(context);
                                            final scaffoldMessenger =
                                                ScaffoldMessenger.of(context);

                                            final error =
                                                await provider.adminUpdateUser(
                                              user.id,
                                              name: nameController.text.trim(),
                                              email:
                                                  emailController.text.trim(),
                                              phone:
                                                  phoneController.text.trim(),
                                              role: selectedRole,
                                              approvalStatus:
                                                  selectedRole == UserRole.owner
                                                      ? selectedApproval
                                                      : null,
                                            );

                                            if (!mounted) return;
                                            navigator.pop();

                                            if (error != null) {
                                              if (!mounted) return;
                                              scaffoldMessenger.showSnackBar(
                                                SnackBar(
                                                  content: Row(
                                                    children: [
                                                      Icon(Icons.error_outline,
                                                          color: Colors.white,
                                                          size: 20),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                          child: Text(error)),
                                                    ],
                                                  ),
                                                  backgroundColor:
                                                      AppColors.error,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8)),
                                                ),
                                              );
                                            } else {
                                              if (!mounted) return;
                                              scaffoldMessenger.showSnackBar(
                                                SnackBar(
                                                  content: Row(
                                                    children: [
                                                      Icon(
                                                          Icons
                                                              .check_circle_outline,
                                                          color: Colors.white,
                                                          size: 20),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                          'User updated successfully'),
                                                    ],
                                                  ),
                                                  backgroundColor:
                                                      AppColors.success,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8)),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: isUpdating
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : Text(
                                          'Update User',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(UserModel user) {
    bool isDeleting = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 16,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon and title
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.05),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.delete_forever_rounded,
                          size: 32,
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Delete User Account',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This action is permanent and cannot be undone',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User info card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.cardBorder.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _roleColor(user.role),
                                    _roleColor(user.role)
                                        .withValues(alpha: 0.7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  user.name.isNotEmpty
                                      ? user.name[0].toUpperCase()
                                      : '?',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user.email,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _roleColor(user.role)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      _roleLabel(user.role),
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: _roleColor(user.role),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Warning section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.warning_rounded,
                              color: Colors.orange.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Data Impact',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'All associated parking spots, bookings, and user data will be permanently removed from the system.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.orange.shade600,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: isDeleting
                                  ? null
                                  : () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: AppColors.cardBorder
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                backgroundColor: Colors.transparent,
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isDeleting
                                  ? null
                                  : () async {
                                      setState(() => isDeleting = true);

                                      final provider =
                                          context.read<AppProvider>();
                                      final navigator = Navigator.of(context);
                                      final scaffoldMessenger =
                                          ScaffoldMessenger.of(context);

                                      final error =
                                          await provider.deleteUser(user.id);

                                      if (!mounted) return;
                                      navigator.pop();

                                      if (error != null) {
                                        if (!mounted) return;
                                        scaffoldMessenger.showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                Icon(Icons.error_outline,
                                                    color: Colors.white,
                                                    size: 20),
                                                const SizedBox(width: 8),
                                                Expanded(child: Text(error)),
                                              ],
                                            ),
                                            backgroundColor: AppColors.error,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                          ),
                                        );
                                      } else {
                                        if (!mounted) return;
                                        scaffoldMessenger.showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                Icon(Icons.check_circle_outline,
                                                    color: Colors.white,
                                                    size: 20),
                                                const SizedBox(width: 8),
                                                Text(
                                                    'User deleted successfully'),
                                              ],
                                            ),
                                            backgroundColor: AppColors.success,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                          ),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: isDeleting
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'Delete User',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
