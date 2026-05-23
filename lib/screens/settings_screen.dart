// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../services/supabase_service.dart';
import 'login_screen.dart';
import 'subscription_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _taxCtrl = TextEditingController(text: '5');
  final _shopNameCtrl = TextEditingController();
  final _shopPhoneCtrl = TextEditingController();
  final _shopAddressCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = SupabaseService.currentUser;
    _shopNameCtrl.text = user?.userMetadata?['shop_name'] ?? 'My Kirana Store';
    _shopPhoneCtrl.text = user?.userMetadata?['phone'] ?? '';
    _shopAddressCtrl.text = user?.userMetadata?['address'] ?? '';
    _taxCtrl.text = user?.userMetadata?['tax_rate']?.toString() ?? '5';
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await SupabaseService.client.auth.updateUser(
        UserAttributes(data: {
          'shop_name': _shopNameCtrl.text,
          'phone': _shopPhoneCtrl.text,
          'address': _shopAddressCtrl.text,
          'tax_rate': double.tryParse(_taxCtrl.text) ?? 5.0,
        }),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Settings saved! ✅'),
          backgroundColor: AppColors.success,
        ));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
            onPressed: () => Navigator.pop(context)),
        title: Text('Settings', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                : Text('Save', style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Upgrade Banner ──────────────────────────
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary.withValues(alpha: 0.25), AppColors.bgCard],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
              ),
              child: Row(children: [
                const Icon(Icons.workspace_premium, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Upgrade to Pro', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                  Text('Starting Rs.299/month — 30 days FREE!', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                  child: Text('Upgrade', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // ── Shop Info ───────────────────────────────
          KiranaCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.store_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Shop Information', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
              ]),
              const SizedBox(height: 16),
              _field('Shop Name', Icons.store_outlined, _shopNameCtrl),
              const SizedBox(height: 12),
              _field('Phone Number', Icons.phone_outlined, _shopPhoneCtrl, type: TextInputType.phone),
              const SizedBox(height: 12),
              _field('Address', Icons.location_on_outlined, _shopAddressCtrl, maxLines: 2),
            ]),
          ),
          const SizedBox(height: 16),

          // ── Tax Settings ────────────────────────────
          KiranaCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.receipt_long_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Tax & Billing', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
              ]),
              const SizedBox(height: 16),
              _field('GST / Tax Rate (%)', Icons.percent, _taxCtrl, type: TextInputType.number),
              const SizedBox(height: 8),
              Text('Current tax: ${_taxCtrl.text}% per bill', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 16),

          // ── App Info ────────────────────────────────
          KiranaCard(
            child: Column(children: [
              _infoTile(Icons.info_outline, 'App Version', 'Kirana AI v1.0.0'),
              const Divider(color: Color(0xFF1E3028)),
              _infoTile(Icons.security_outlined, 'Data Security', 'End-to-end encrypted'),
              const Divider(color: Color(0xFF1E3028)),
              _infoTile(Icons.cloud_outlined, 'Backend', 'Supabase Cloud'),
            ]),
          ),
          const SizedBox(height: 16),

          // ── Account ─────────────────────────────────
          KiranaCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Account', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _confirmLogout(),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.logout, color: AppColors.error, size: 20),
                    const SizedBox(width: 12),
                    Text('Logout', style: GoogleFonts.inter(color: AppColors.error, fontWeight: FontWeight.w600, fontSize: 14)),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: AppColors.error, size: 18),
                  ]),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          KiranaPrimaryButton(label: 'Save Settings', icon: Icons.check, isLoading: _saving, onPressed: _saving ? () {} : _save),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Logout', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to logout?', style: GoogleFonts.inter(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await SupabaseService.logout();
              if (mounted) Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Logout', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, IconData icon, TextEditingController ctrl, {TextInputType? type, int maxLines = 1}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl, keyboardType: type, maxLines: maxLines,
        style: GoogleFonts.inter(color: AppColors.textPrimary),
        decoration: InputDecoration(prefixIcon: Icon(icon, color: AppColors.textMuted, size: 18)),
      ),
    ]);
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, color: AppColors.textMuted, size: 18),
        const SizedBox(width: 12),
        Text(title, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
        const Spacer(),
        Text(value, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
