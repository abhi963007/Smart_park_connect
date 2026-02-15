import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../models/user_model.dart';

/// Screen shown to owners who are pending approval or have been rejected
class OwnerPendingScreen extends StatelessWidget {
  const OwnerPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Owner Dashboard',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _getStatusColor(user.approvalStatus).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(user.approvalStatus),
                  size: 60,
                  color: _getStatusColor(user.approvalStatus),
                ),
              ),
              const SizedBox(height: 32),

              // Status title
              Text(
                _getStatusTitle(user.approvalStatus),
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Status message
              Text(
                _getStatusMessage(user.approvalStatus),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Status details card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Registration Details',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Name', user.name),
                    _buildDetailRow('Email', user.email),
                    _buildDetailRow('Role', 'Parking Owner'),
                    _buildDetailRow('Status', user.approvalStatusText),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action based on status
              if (user.isPendingApproval) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your registration is being reviewed by our admin team. You\'ll be notified once approved.',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (user.isRejected) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Please contact support for more information about your registration.',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Add contact support functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Contact support at support@smartparkconnect.com',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Contact Support',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textHint,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.pending:
        return AppColors.warning;
      case ApprovalStatus.rejected:
        return AppColors.error;
      case ApprovalStatus.approved:
        return AppColors.success;
    }
  }

  IconData _getStatusIcon(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.pending:
        return Icons.schedule;
      case ApprovalStatus.rejected:
        return Icons.cancel;
      case ApprovalStatus.approved:
        return Icons.check_circle;
    }
  }

  String _getStatusTitle(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.pending:
        return 'Approval Pending';
      case ApprovalStatus.rejected:
        return 'Registration Rejected';
      case ApprovalStatus.approved:
        return 'Approved';
    }
  }

  String _getStatusMessage(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.pending:
        return 'Your owner registration is currently under review. Once approved by our admin team, you\'ll be able to add and manage parking spots.';
      case ApprovalStatus.rejected:
        return 'Unfortunately, your owner registration was not approved. This could be due to incomplete information or policy violations.';
      case ApprovalStatus.approved:
        return 'Congratulations! Your owner registration has been approved. You can now add and manage parking spots.';
    }
  }
}
