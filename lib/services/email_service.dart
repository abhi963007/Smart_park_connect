import 'dart:convert';
import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Email service for OTP verification using Gmail SMTP (Nodemailer-style)
///
/// Setup instructions:
/// 1. Go to https://myaccount.google.com/security
/// 2. Enable 2-Step Verification
/// 3. Go to https://myaccount.google.com/apppasswords
/// 4. Generate an App Password for "Mail"
/// 5. Replace the credentials below with your Gmail + App Password
class EmailService {
  // ─── Gmail SMTP Configuration ───
  // Replace these with your actual Gmail credentials
  static const String _senderEmail = 'windsurf01963@gmail.com';
  static const String _senderPassword = 'aqqglqkimtunrnmj'; // Gmail App Password
  static const String _senderName = 'SmartPark Connect';

  static const String _otpStorageKey = 'pending_otps';
  static const int _otpExpiryMinutes = 5;

  /// Generate a 6-digit OTP
  static String _generateOTP() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Send OTP to user's email address via Gmail SMTP
  static Future<bool> sendOTP(String email, {String? userName}) async {
    try {
      final otp = _generateOTP();
      final expiryTime = DateTime.now().add(const Duration(minutes: _otpExpiryMinutes));

      // Store OTP locally with expiry
      await _storeOTP(email, otp, expiryTime);

      // Send actual email via Gmail SMTP
      final sent = await _sendEmail(
        toEmail: email,
        userName: userName ?? 'User',
        otp: otp,
        subject: 'SmartPark Connect - Your Verification Code',
        isReset: false,
      );

      if (!sent) {
        // If email fails, still keep OTP stored for demo/testing
        print('⚠️ Email sending failed, but OTP is stored locally for testing');
        print('=== OTP (for testing) ===');
        print('Email: $email | OTP: $otp');
        print('=========================');
      }

      return true; // OTP generated and stored regardless
    } catch (e) {
      print('Error in sendOTP: $e');
      return false;
    }
  }

  /// Send actual email via Gmail SMTP (like Nodemailer)
  static Future<bool> _sendEmail({
    required String toEmail,
    required String userName,
    required String otp,
    required String subject,
    required bool isReset,
  }) async {
    try {
      // Configure Gmail SMTP server
      final smtpServer = gmail(_senderEmail, _senderPassword);

      // Build the email message
      final message = Message()
        ..from = Address(_senderEmail, _senderName)
        ..recipients.add(toEmail)
        ..subject = subject
        ..html = _buildEmailTemplate(
          userName: userName,
          otp: otp,
          isReset: isReset,
        );

      // Send the email
      final sendReport = await send(message, smtpServer);
      print('✅ OTP email sent to $toEmail: $sendReport');
      return true;
    } on MailerException catch (e) {
      print('❌ Email sending failed: ${e.message}');
      for (var p in e.problems) {
        print('  Problem: ${p.code}: ${p.msg}');
      }
      return false;
    } catch (e) {
      print('❌ Email error: $e');
      return false;
    }
  }

  /// Build HTML email template
  static String _buildEmailTemplate({
    required String userName,
    required String otp,
    required bool isReset,
  }) {
    final action = isReset ? 'reset your password' : 'verify your email';
    final title = isReset ? 'Password Reset' : 'Email Verification';

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin:0;padding:0;background-color:#f4f4f4;font-family:Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background-color:#f4f4f4;padding:40px 0;">
    <tr>
      <td align="center">
        <table width="400" cellpadding="0" cellspacing="0" style="background-color:#ffffff;border-radius:12px;overflow:hidden;box-shadow:0 2px 12px rgba(0,0,0,0.1);">
          <!-- Header -->
          <tr>
            <td style="background-color:#4A3AFF;padding:30px;text-align:center;">
              <h1 style="color:#ffffff;margin:0;font-size:22px;">🅿️ SmartPark Connect</h1>
              <p style="color:#c8c4ff;margin:8px 0 0;font-size:14px;">$title</p>
            </td>
          </tr>
          <!-- Body -->
          <tr>
            <td style="padding:30px;">
              <p style="color:#333;font-size:16px;margin:0 0 10px;">Hello <strong>$userName</strong>,</p>
              <p style="color:#666;font-size:14px;line-height:1.6;margin:0 0 25px;">
                Use the following verification code to $action. This code is valid for <strong>5 minutes</strong>.
              </p>
              <!-- OTP Box -->
              <div style="background-color:#f0eeff;border:2px dashed #4A3AFF;border-radius:10px;padding:20px;text-align:center;margin:0 0 25px;">
                <p style="color:#888;font-size:12px;margin:0 0 8px;text-transform:uppercase;letter-spacing:2px;">Your OTP Code</p>
                <h2 style="color:#4A3AFF;font-size:36px;margin:0;letter-spacing:8px;font-weight:700;">$otp</h2>
              </div>
              <p style="color:#999;font-size:12px;line-height:1.5;margin:0;">
                ⚠️ Do not share this code with anyone.<br>
                If you didn't request this, please ignore this email.
              </p>
            </td>
          </tr>
          <!-- Footer -->
          <tr>
            <td style="background-color:#f9f9f9;padding:20px;text-align:center;border-top:1px solid #eee;">
              <p style="color:#aaa;font-size:11px;margin:0;">© 2025 SmartPark Connect. All rights reserved.</p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
''';
  }

  /// Verify OTP code entered by user
  static Future<bool> verifyOTP(String email, String enteredOTP) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final otpData = prefs.getString(_otpStorageKey);

      if (otpData == null) return false;

      final Map<String, dynamic> otpMap = jsonDecode(otpData);
      final storedData = otpMap[email.toLowerCase()];

      if (storedData == null) return false;

      final String storedOTP = storedData['otp'];
      final DateTime expiryTime = DateTime.parse(storedData['expiry']);

      // Check if OTP has expired
      if (DateTime.now().isAfter(expiryTime)) {
        await _removeOTP(email);
        return false;
      }

      // Check if OTP matches
      if (storedOTP == enteredOTP) {
        await _removeOTP(email);
        return true;
      }

      return false;
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }

  /// Store OTP with expiry time
  static Future<void> _storeOTP(String email, String otp, DateTime expiryTime) async {
    final prefs = await SharedPreferences.getInstance();
    final existingData = prefs.getString(_otpStorageKey);

    Map<String, dynamic> otpMap = {};
    if (existingData != null) {
      otpMap = jsonDecode(existingData);
    }

    otpMap[email.toLowerCase()] = {
      'otp': otp,
      'expiry': expiryTime.toIso8601String(),
    };

    await prefs.setString(_otpStorageKey, jsonEncode(otpMap));
  }

  /// Remove OTP after verification or expiry
  static Future<void> _removeOTP(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final existingData = prefs.getString(_otpStorageKey);

    if (existingData != null) {
      final Map<String, dynamic> otpMap = jsonDecode(existingData);
      otpMap.remove(email.toLowerCase());

      if (otpMap.isEmpty) {
        await prefs.remove(_otpStorageKey);
      } else {
        await prefs.setString(_otpStorageKey, jsonEncode(otpMap));
      }
    }
  }

  /// Get remaining time for OTP
  static Future<Duration?> getRemainingTime(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final otpData = prefs.getString(_otpStorageKey);

    if (otpData == null) return null;

    final Map<String, dynamic> otpMap = jsonDecode(otpData);
    final storedData = otpMap[email.toLowerCase()];

    if (storedData == null) return null;

    final DateTime expiryTime = DateTime.parse(storedData['expiry']);
    final now = DateTime.now();

    if (now.isAfter(expiryTime)) return null;

    return expiryTime.difference(now);
  }
}
