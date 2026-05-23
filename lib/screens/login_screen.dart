// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../services/supabase_service.dart';
import 'employee_login_screen.dart';
import 'main_shell.dart';
import 'reset_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter email and password');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final response = await SupabaseService.loginWithEmail(
        email: email, password: password,
      );
      if (response.user != null && mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const MainShell()));
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = _friendlyError(e.message));
    } catch (e) {
      setState(() => _errorMessage = 'Something went wrong, please try again');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyError(String msg) {
    if (msg.contains('Invalid login')) return 'Email ya password galat hai';
    if (msg.contains('Email not confirmed')) return 'Pehle email verify karo';
    if (msg.contains('network')) return 'Internet connection check karo';
    return msg;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.store_outlined, color: AppColors.primary, size: 28),
                ),
                const SizedBox(height: 16),
                Text('Kirana AI', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Welcome Back', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('Log in to manage your digital\ninventory and sales.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF1E3028)),
                  ),
                  child: Column(
                    children: [
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.error.withOpacity(0.3)),
                          ),
                          child: Row(children: [
                            const Icon(Icons.error_outline, color: AppColors.error, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_errorMessage!, style: GoogleFonts.inter(color: AppColors.error, fontSize: 13))),
                          ]),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _labeledField('Email', 'Enter your email', Icons.person_outline, _emailController, type: TextInputType.emailAddress),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text('Password', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResetPasswordScreen())),
                              child: Text('Forgot Password?', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w500)),
                            ),
                          ]),
                          const SizedBox(height: 6),
                          _PasswordField(controller: _passwordController),
                        ],
                      ),
                      const SizedBox(height: 24),
                      KiranaPrimaryButton(label: 'Login as Owner', icon: Icons.arrow_forward, isLoading: _isLoading, onPressed: _isLoading ? () {} : _login),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(child: Divider(color: AppColors.textMuted.withOpacity(0.3))),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('OR', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12))),
                        Expanded(child: Divider(color: AppColors.textMuted.withOpacity(0.3))),
                      ]),
                      const SizedBox(height: 16),
                      KiranaPrimaryButton(label: 'Login as Employee', isOutlined: true,
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployeeLoginScreen()))),
                      const SizedBox(height: 16),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('New account? ', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
                          child: Text('Sign Up', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text('© 2025 Kirana AI. Secure access for authorized personnel only.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11, height: 1.5)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _labeledField(String label, String hint, IconData icon, TextEditingController ctrl, {TextInputType? type}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      TextField(controller: ctrl, keyboardType: type,
          style: GoogleFonts.inter(color: AppColors.textPrimary),
          decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: AppColors.textMuted, size: 18))),
    ]);
  }
}

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  const _PasswordField({required this.controller});
  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      style: GoogleFonts.inter(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: '••••••••',
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMuted, size: 18),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textMuted, size: 18),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}

// ─── Sign Up Screen ───────────────────────────
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _success = false;

  Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please fill all fields');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      await SupabaseService.signUp(email: email, password: password, name: name);
      setState(() => _success = true);
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Kuch galat hua');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: KiranaAppBar(title: 'Kirana AI', showNotification: false,
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary), onPressed: () => Navigator.pop(context))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _success ? _successView() : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Account', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('Apna Kirana AI account banao', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF1E3028))),
                child: Column(children: [
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text(_errorMessage!, style: GoogleFonts.inter(color: AppColors.error, fontSize: 13)),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _field('Shop / Owner Name', 'Ramesh Kirana Store', Icons.store_outlined, _nameController),
                  const SizedBox(height: 14),
                  _field('Email', 'name@example.com', Icons.email_outlined, _emailController, type: TextInputType.emailAddress),
                  const SizedBox(height: 14),
                  _field('Password', '6+ characters', Icons.lock_outline, _passwordController, isPassword: true),
                  const SizedBox(height: 24),
                  KiranaPrimaryButton(label: 'Create Account', icon: Icons.arrow_forward, isLoading: _isLoading, onPressed: _isLoading ? () {} : _signUp),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _successView() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const SizedBox(height: 60),
      Container(padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.success.withOpacity(0.15), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle_outline, color: AppColors.success, size: 48)),
      const SizedBox(height: 20),
      Text('Account Created! 🎉', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
      const SizedBox(height: 10),
      Text('Email verify karo — inbox check karo\naur link pe click karo',
          textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
      const SizedBox(height: 30),
      KiranaPrimaryButton(label: 'Login Now', icon: Icons.arrow_forward, onPressed: () => Navigator.pop(context)),
    ]));
  }

  Widget _field(String label, String hint, IconData icon, TextEditingController ctrl, {TextInputType? type, bool isPassword = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      TextField(controller: ctrl, obscureText: isPassword, keyboardType: type,
          style: GoogleFonts.inter(color: AppColors.textPrimary),
          decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: AppColors.textMuted, size: 18))),
    ]);
  }
}
