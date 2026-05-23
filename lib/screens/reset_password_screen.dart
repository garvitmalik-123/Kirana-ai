// lib/screens/reset_password_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../services/supabase_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Email daalo');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      await SupabaseService.resetPassword(email);
      setState(() => _emailSent = true);
    } catch (e) {
      setState(() => _errorMessage = 'Email send nahi hua, dobara try karo');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Color(0xFF0D3020), AppColors.bgDark],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _emailSent ? _successView() : _formView(),
          ),
        ),
      ),
    );
  }

  Widget _formView() {
    return Column(children: [
      const SizedBox(height: 60),
      Container(
        width: 72, height: 72,
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.lock_reset, color: Colors.black, size: 34),
      ),
      const SizedBox(height: 24),
      Text('Reset Password', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      Text('Apna registered email daalo\nreset link milega', textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
      const SizedBox(height: 40),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.bgCard.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1E3028)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('EMAIL', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.1)),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.inter(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'name@example.com', prefixIcon: Icon(Icons.person_outline, color: AppColors.textMuted, size: 18)),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(_errorMessage!, style: GoogleFonts.inter(color: AppColors.error, fontSize: 13)),
          ],
          const SizedBox(height: 20),
          KiranaPrimaryButton(label: 'Send Reset Link', icon: Icons.arrow_forward, isLoading: _isLoading, onPressed: _isLoading ? () {} : _sendOtp),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.chevron_left, size: 16, color: AppColors.textSecondary),
                Text('Back to Login', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
              ]),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 48),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.shield_outlined, color: AppColors.textMuted, size: 14),
        const SizedBox(width: 6),
        Text('SECURE AUTH', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1)),
        const SizedBox(width: 16),
        Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.textMuted, shape: BoxShape.circle)),
        const SizedBox(width: 16),
        const Icon(Icons.shield_outlined, color: AppColors.textMuted, size: 14),
        const SizedBox(width: 6),
        Text('END-TO-END', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1)),
      ]),
    ]);
  }

  Widget _successView() {
    return Column(children: [
      const SizedBox(height: 80),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.success.withOpacity(0.15), shape: BoxShape.circle),
        child: const Icon(Icons.mark_email_read_outlined, color: AppColors.success, size: 48),
      ),
      const SizedBox(height: 24),
      Text('Email Bhej Diya! ✅', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      Text('${_emailController.text} pe\nreset link gaya hai.\nInbox check karo!',
          textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14, height: 1.6)),
      const SizedBox(height: 40),
      KiranaPrimaryButton(label: 'Back to Login', icon: Icons.arrow_back, onPressed: () => Navigator.pop(context)),
    ]);
  }
}
