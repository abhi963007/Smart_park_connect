import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../services/email_service.dart';
import '../../services/local_storage_service.dart';
import 'otp_verification_screen.dart';

/// Forgot password screen with email input and OTP verification
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;
  bool _isEmailVerified = false;
  String? _verifiedEmail;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendResetOTP() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter your email address');
      return;
    }

    // Validate email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      setState(() => _errorMessage = 'Please enter a valid email address');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if email exists in registered users
      final users = await LocalStorageService.getAllUsers();
      final user = users
          .where((u) =>
              u.email.toLowerCase() ==
              _emailController.text.trim().toLowerCase())
          .firstOrNull;

      if (user == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No account found with this email address';
        });
        return;
      }

      // Send OTP to email
      final otpSent = await EmailService.sendOTP(
        _emailController.text.trim(),
        userName: user.name,
      );

      setState(() => _isLoading = false);

      if (otpSent) {
        if (!mounted) return;
        // Navigate to OTP verification screen
        final verified = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              email: _emailController.text.trim(),
              userName: user.name,
              title: 'Reset Password',
              subtitle:
                  'Enter the 6-digit code sent to your email to reset your password',
              onVerificationSuccess: () {
                // This will be called when OTP is verified
              },
            ),
          ),
        );

        // If OTP was verified, allow password reset
        if (verified == true) {
          setState(() {
            _isEmailVerified = true;
            _verifiedEmail = _emailController.text.trim();
            _errorMessage = null;
          });
        }
      } else {
        setState(() =>
            _errorMessage = 'Failed to send reset code. Please try again.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final error = await context.read<AppProvider>().resetPassword(
            _verifiedEmail!,
            _newPasswordController.text,
          );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (error != null) {
        setState(() => _errorMessage = error);
      } else {
        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset successfully!'),
            backgroundColor: AppColors.success,
          ),
        );

        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to reset password. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Reset Password',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    kToolbarHeight -
                    48, // Account for padding and app bar
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Lock icon
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_reset_outlined,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    if (!_isEmailVerified) ...[
                      // Email verification step
                      Text(
                        'Forgot Password?',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Enter your email address and we\'ll send you a verification code to reset your password.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Email field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          labelStyle: GoogleFonts.poppins(
                              color: AppColors.textSecondary),
                          prefixIcon: const Icon(Icons.email_outlined,
                              color: AppColors.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.cardBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: AppColors.backgroundLight,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          final emailRegex =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                    ] else ...[
                      // Password reset step
                      Text(
                        'Create New Password',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Your email has been verified. Please create a new password for your account.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // New password field
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscurePassword,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          labelStyle: GoogleFonts.poppins(
                              color: AppColors.textSecondary),
                          prefixIcon: const Icon(Icons.lock_outlined,
                              color: AppColors.primary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.cardBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: AppColors.backgroundLight,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Confirm password field
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          labelStyle: GoogleFonts.poppins(
                              color: AppColors.textSecondary),
                          prefixIcon: const Icon(Icons.lock_outlined,
                              color: AppColors.primary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.cardBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: AppColors.backgroundLight,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Error message
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.error, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const Expanded(child: SizedBox()),

                    // Action button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : (_isEmailVerified
                                ? _resetPassword
                                : _sendResetOTP),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isEmailVerified
                                    ? 'Reset Password'
                                    : 'Send Verification Code',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
