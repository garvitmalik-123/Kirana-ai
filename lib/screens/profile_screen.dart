// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../services/supabase_service.dart';
import 'login_screen.dart';
import 'subscription_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _shopCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  bool _isSaving = false;
  String? _successMsg;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = SupabaseService.currentUser;
      if (user != null) {
        _emailCtrl.text = user.email ?? '';
        _nameCtrl.text = user.userMetadata?['name'] ?? '';
        _phoneCtrl.text = user.userMetadata?['phone'] ?? '';
        _shopCtrl.text = user.userMetadata?['shop_name'] ?? '';
      }
    } catch (e) {
      setState(() => _errorMsg = 'Profile load nahi hua');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() { _isSaving = true; _successMsg = null; _errorMsg = null; });
    try {
      await SupabaseService.client.auth.updateUser(
        UserAttributes(
          data: {
            'name': _nameCtrl.text.trim(),
            'phone': _phoneCtrl.text.trim(),
            'shop_name': _shopCtrl.text.trim(),
          },
        ),
      );
      setState(() => _successMsg = 'Profile updated successfully! ✅');
    } catch (e) {
      setState(() => _errorMsg = 'Save failed: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _changePassword() async {
    final newPassCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Change Password', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: newPassCtrl,
            obscureText: true,
            style: GoogleFonts.inter(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'New Password (6+ chars)', prefixIcon: Icon(Icons.lock_outline, color: AppColors.textMuted, size: 18)),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              if (newPassCtrl.text.length < 6) return;
              try {
                await SupabaseService.client.auth.updateUser(
                  UserAttributes(password: newPassCtrl.text),
                );
                if (mounted) {
                  Navigator.pop(context);
                  setState(() => _successMsg = 'Password updated successfully! ✅');
                }
              } catch (e) {
                if (mounted) Navigator.pop(context);
                setState(() => _errorMsg = 'Password update failed');
              }
            },
            child: Text('Update', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Logout', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: Text('Kya aap logout karna chahte hain?', style: GoogleFonts.inter(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await SupabaseService.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Logout', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _shopCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('My Profile', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                : Text('Save', style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                // Avatar
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                        child: Text(
                          _nameCtrl.text.isNotEmpty ? _nameCtrl.text[0].toUpperCase() : 'U',
                          style: GoogleFonts.inter(color: AppColors.primary, fontSize: 36, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt_outlined, color: Colors.black, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(_emailCtrl.text, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 24),

                // Success / Error messages
                if (_successMsg != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.success.withValues(alpha: 0.3))),
                    child: Row(children: [
                      const Icon(Icons.check_circle_outline, color: AppColors.success, size: 16),
                      const SizedBox(width: 8),
                      Text(_successMsg!, style: GoogleFonts.inter(color: AppColors.success, fontSize: 13)),
                    ]),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_errorMsg != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.error.withValues(alpha: 0.3))),
                    child: Row(children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_errorMsg!, style: GoogleFonts.inter(color: AppColors.error, fontSize: 13))),
                    ]),
                  ),
                  const SizedBox(height: 16),
                ],

                // Form fields
                KiranaCard(
                  child: Column(children: [
                    Text('Personal Info', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 16),
                    _editField('Owner Name', Icons.person_outline, _nameCtrl),
                    const SizedBox(height: 14),
                    _editField('Phone Number', Icons.phone_outlined, _phoneCtrl, type: TextInputType.phone),
                    const SizedBox(height: 14),
                    _editField('Shop Name', Icons.store_outlined, _shopCtrl),
                    const SizedBox(height: 14),
                    _editField('Email', Icons.email_outlined, _emailCtrl, enabled: false),
                  ]),
                ),
                const SizedBox(height: 16),

                // Actions
                KiranaCard(
                  child: Column(children: [
                    Text('Account', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 12),
                    _actionTile(Icons.workspace_premium, 'Upgrade Plan', 'Unlock Pro features', AppColors.primary,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()))),
              const Divider(color: Color(0xFF1E3028)),
              _actionTile(Icons.lock_outline, 'Change Password', 'Update your password', AppColors.info, _changePassword),
                    const Divider(color: Color(0xFF1E3028)),
                    _actionTile(Icons.logout, 'Logout', 'Sign out of your account', AppColors.error, _logout),
                  ]),
                ),
                const SizedBox(height: 24),

                // Save button
                KiranaPrimaryButton(
                  label: 'Save Changes',
                  icon: Icons.check,
                  isLoading: _isSaving,
                  onPressed: _isSaving ? () {} : _saveProfile,
                ),
                const SizedBox(height: 24),
              ]),
            ),
    );
  }

  Widget _editField(String label, IconData icon, TextEditingController ctrl, {TextInputType? type, bool enabled = true}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        keyboardType: type,
        enabled: enabled,
        style: GoogleFonts.inter(color: enabled ? AppColors.textPrimary : AppColors.textMuted),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.textMuted, size: 18),
          fillColor: enabled ? AppColors.bgSurface : AppColors.bgSurface.withValues(alpha: 0.5),
        ),
      ),
    ]);
  }

  Widget _actionTile(IconData icon, String title, String sub, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20)),
      title: Text(title, style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(sub, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
      trailing: Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }
}
